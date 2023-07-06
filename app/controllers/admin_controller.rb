# frozen_string_literal: true

class AdminController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:twilio_messaging]
  skip_before_action :verify_authenticity_token, only: [:twilio_messaging] # do not use CSRF token checking for API routes
  before_action :signed_in_admin, except: [:twilio_messaging]

  layout "application"

  def twilio_messaging
    ::MfaCodeService::Create.new(message: params[:Body]).run

    # Don't reply to incoming sms message
    # https://support.twilio.com/hc/en-us/articles/223134127-Receive-SMS-and-MMS-Messages-without-Responding
    respond_to do |format|
      format.xml { render xml: "<Response></Response>" }
    end
  end

  def tasks
    @active = pending_tasks
    @pending_actions = @active.values.any? { |e| e.nonzero? }
    @blankslate_message = [
      "You look great today, #{current_user.first_name}.",
      "You’re a *credit* to your team, #{current_user.first_name}.",
      "Everybody thinks you’re amazing, #{current_user.first_name}.",
      "You’re every organizer’s favorite team member.",
      "You’re so good at finances, even we think your balance is outstanding.",
      "You’re sweeter than a savings account.",
      "Though they don't show it off, those flowers sure are pretty."
    ].sample
  end

  def task_size
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    size = pending_task params[:task_name].to_sym
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    render json: { elapsed:, size: }, status: 200
  end

  def search
    # allows the same URL to easily be used for form and GET
    return if request.method == "GET"

    # removing dashes to deal with phone number
    query = params[:q].gsub("-", "").strip

    users = []

    users.push(User.where("full_name ilike ?", "%#{query.downcase}%").includes(:events))
    users.push(User.where(email: query).includes(:events))
    users.push(User.where(phone_number: query).includes(:events))

    @result = users.flatten.compact
  end

  def negative_events
    @negative_events = Event.negatives
  end

  def transaction
    @canonical_transaction = CanonicalTransaction.find(params[:id])
    @hcb_code = @canonical_transaction.local_hcb_code

    # potentials
    @potential_donation_payouts = DonationPayout.donation_hcb_code.where(amount: @canonical_transaction.amount_cents)
    @potential_invoice_payouts = InvoicePayout.invoice_hcb_code.where(amount: @canonical_transaction.amount_cents)

    # other
    @canonical_pending_transactions = CanonicalPendingTransaction.unmapped.where(amount_cents: @canonical_transaction.amount_cents)
    @ahoy_events = Ahoy::Event.where("name in (?) and (properties->'canonical_transaction'->>'id')::int = ?", [::SystemEventService::Write::SettledTransactionMapped::NAME, ::SystemEventService::Write::SettledTransactionCreated::NAME], @canonical_transaction.id).order("time desc")

    render layout: "admin"
  end

  def partners
    relation = Partner

    @partners = relation.all

    @count = relation.count

    render layout: "admin"
  end

  def partner
    @partner = Partner.find(params.require(:id))
    render layout: "admin"
  end

  def partner_edit
    @partner = Partner.find(params.require(:id))
    edit_params = params.require(:partner).permit(
      :docusign_template_id
    )
    @partner.update!(edit_params)
    flash[:success] = "Partner updated"
    redirect_to partners_admin_index_path
  end

  def partnered_signup_sign_document
    @partnered_signup = PartneredSignup.find(params.require(:id))

    # Do not allow admins to sign if the applicant has not already signec
    unless @partnered_signup.applicant_signed?
      flash[:error] = "Applicant has not signed yet!"
      redirect_to partnered_signups_admin_index_path and return
    end

    admin_contract_signing = Partners::Docusign::AdminContractSigning.new(@partnered_signup)
    redirect_to admin_contract_signing.admin_signing_link, allow_other_host: true
  end

  def partnered_signups
    relation = PartneredSignup

    @partnered_signups = relation.not_unsubmitted

    @count = @partnered_signups.count

    render layout: "admin"
  end

  def partnered_signups_accept
    @partnered_signup = PartneredSignup.find(params[:id])
    @partner = @partnered_signup.partner

    authorize @partnered_signup

    PartneredSignup.transaction do
      # Create an event
      @organization = Event.create!(
        partner: @partner,
        name: @partnered_signup.organization_name,
        sponsorship_fee: @partner.default_org_sponsorship_fee,
        organization_identifier: SecureRandom.hex(30) + @partnered_signup.organization_name,
      )

      # Invite users to event
      ::EventService::PartnerInviteUser.new(
        partner: @partner,
        event: @organization,
        user_email: @partnered_signup.owner_email
      ).run

      # Record the org & user in the signup
      @partnered_signup.update(
        event: @organization,
        user: User.find_by(email: @partnered_signup.owner_email),
      )

      # Mark the signup as completed
      # TODO: remove bypass for unapproved (unsigned contracts by admin)
      @partnered_signup.mark_accepted! if @partnered_signup.applicant_signed?
      @partnered_signup.mark_completed!

      ::PartneredSignupJob::DeliverWebhook.perform_later(@partnered_signup.id)
      flash[:success] = "Partner signup accepted"
      redirect_to partnered_signups_admin_index_path and return
    end
  rescue => e
    notify_airbrake(e)

    # Something went wrong
    flash[:error] = "Something went wrong. #{e}"
    redirect_to partnered_signups_admin_index_path
  end

  def partnered_signups_reject
    @partnered_signup = PartneredSignup.find(params[:id])
    @partner = @partnered_signup.partner
    @partnered_signup.rejected_at = Time.now
    authorize @partnered_signup

    if @partnered_signup.save
      ::PartneredSignupJob::DeliverWebhook.perform_later(@partnered_signup.id)
      flash[:success] = "Partner signup rejected"
      redirect_to partnered_signups_admin_index_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def partner_organizations
    @page = params[:page] || 1
    @per = params[:per] || 100

    relation = Event.partner

    @count = relation.count

    @partner_organizations = relation.page(@page).per(@per).reorder("created_at desc")

    render layout: "admin"
  end

  def events
    @page = params[:page] || 1
    @per = params[:per] || 100

    @events = filtered_events.page(@page).per(@per).reorder(Arel.sql("COALESCE(events.activated_at, events.created_at) desc"))
    @count = @events.count

    render layout: "admin"
  end

  def event_process
    @event = Event.find(params[:id])

    render layout: "admin"
  end

  def event_new
    render layout: "admin"
  end

  def event_create
    emails = [params[:organizer_email]].reject(&:empty?)

    ::EventService::Create.new(
      name: params[:name],
      emails:,
      is_signee: params[:is_signee].to_i == 1,
      country: params[:country],
      category: params[:category],
      point_of_contact_id: params[:point_of_contact_id],
      approved: params[:approved].to_i == 1,
      is_public: params[:is_public].to_i == 1,
      sponsorship_fee: params[:sponsorship_fee],
      organized_by_hack_clubbers: params[:organized_by_hack_clubbers].to_i == 1,
      organized_by_teenagers: params[:organized_by_teenagers].to_i == 1,
      omit_stats: params[:omit_stats].to_i == 1,
      demo_mode: params[:demo_mode].to_i == 1
    ).run

    redirect_to events_admin_index_path, flash: { success: "Successfully created #{params[:name]}" }
  rescue => e
    redirect_to event_new_admin_index_path, flash: { error: e.message }
  end

  def event_balance
    @event = Event.find(params[:id])
    @balance = Rails.cache.fetch("admin_event_balance_#{@event.id}", expires_in: 5.minutes) do
      @event.balance.to_i
    end
    render :event_balance, layout: false
  end

  def event_toggle_approved
    @event = Event.find(params[:id])

    state = ::EventService::ToggleApproved.new(@event).run

    redirect_to event_process_admin_path(@event), flash: { success: "Successfully marked as #{state}" }
  rescue => e
    redirect_to event_process_admin_path(@event), flash: { error: e.message }
  end

  def event_reject
    @event = Event.find(params[:id])

    state = ::EventService::Reject.new(@event).run

    redirect_to event_process_admin_path(@event), flash: { success: "Event has been #{state}" }
  rescue => e
    redirect_to event_process_admin_path(@event), flash: { error: e.message }
  end

  def bank_fees
    @page = params[:page] || 1
    @per = params[:per] || 100
    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.bank_fees
    else
      relation = BankFee
    end

    @count = relation.count
    @sum = relation.sum(:amount_cents)

    @bank_fees = relation.page(@page).per(@per).order("bank_fees.created_at desc")

    render layout: "admin"
  end

  def users
    @page = params[:page] || 1
    @per = params[:per] || 100
    @q = params[:q].present? ? params[:q] : nil
    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.users.includes(:events)
    else
      relation = User.includes(:events)
    end

    relation = relation.search_name(@q) if @q

    @count = relation.count

    @users = relation.page(@page).per(@per).order(created_at: :desc)

    render layout: "admin"
  end

  def bank_accounts
    relation = BankAccount

    @count = relation.count

    @bank_accounts = relation.all.order("id asc")

    render layout: "admin"
  end

  def raw_transactions
    @page = params[:page] || 1
    @per = params[:per] || 100
    @unique_bank_identifier = params[:unique_bank_identifier].present? ? params[:unique_bank_identifier] : nil

    relation = RawCsvTransaction
    relation = relation.where(unique_bank_identifier: @unique_bank_identifier) if @unique_bank_identifier

    @count = relation.count

    @raw_transactions = relation.page(@page).per(@per).order("date_posted desc")

    render layout: "admin"
  end

  def raw_transaction_new
    render layout: "admin"
  end

  def raw_transaction_create
    ::RawCsvTransactionService::Create.new(
      unique_bank_identifier: params[:unique_bank_identifier],
      date: params[:date],
      memo: params[:memo],
      amount: params[:amount]
    ).run

    redirect_to raw_transactions_admin_index_path, flash: { success: "Success" }
  rescue => e
    redirect_to raw_transaction_new_admin_index_path, flash: { error: e.message }
  end

  def ledger
    @page = params[:page] || 1
    @per = params[:per] || 100
    @q = params[:q].present? ? params[:q] : nil
    @unmapped = params[:unmapped] != "0"
    @exclude_top_ups = params[:exclude_top_ups] == "1" ? true : nil
    @mapped_by_human = params[:mapped_by_human] == "1" ? true : nil
    @event_id = params[:event_id].present? ? params[:event_id] : nil
    @user_id = params[:user_id].present? ? params[:user_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.canonical_transactions.includes(:canonical_event_mapping)
    else
      relation = CanonicalTransaction.includes(:canonical_event_mapping)
    end

    if @q
      if @q.to_f != 0.0
        @q = Monetize.parse(@q).cents

        relation = relation.where("amount_cents = ? or amount_cents = ?", @q, -@q)
      else
        case @q.delete(" ")
        when ">0", ">=0"
          relation = relation.where("amount_cents >= 0")
        when "<0", "<=0"
          relation = relation.where("amount_cents <= 0")
        else
          relation = relation.search_memo(@q)
        end
      end
    end

    relation = relation.unmapped if @unmapped
    relation = relation.not_stripe_top_up if @exclude_top_ups
    relation = relation.mapped_by_human if @mapped_by_human

    if @user_id
      user = User.find(@user_id)
      sch_sid = user&.stripe_cardholder&.stripe_id
      relation = relation.stripe_transaction
                         .where("raw_stripe_transactions.stripe_transaction->>'cardholder' = ?", sch_sid)
    end

    @count = relation.count

    @canonical_transactions = relation.page(@page).per(@per).order(date: :desc)

    render layout: "admin"
  end

  def pending_ledger
    @page = params[:page] || 1
    @per = params[:per] || 100
    @q = params[:q].present? ? params[:q] : nil
    @unsettled = params[:unsettled] == "1" ? true : nil
    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.canonical_pending_transactions.includes(:canonical_pending_event_mapping)
    else
      relation = CanonicalPendingTransaction.includes(:canonical_pending_event_mapping)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount_cents = ? or amount_cents = ?", @q, -@q)
      else
        case @q.delete(" ")
        when ">0", ">=0"
          relation = relation.where("amount_cents >= 0")
        when "<0", "<=0"
          relation = relation.where("amount_cents <= 0")
        else
          relation = relation.search_memo(@q)
        end
      end
    end

    relation = relation.unsettled if @unsettled

    @count = relation.count

    @canonical_pending_transactions = relation.page(@page).per(@per).order("date desc")

    render layout: "admin"
  end

  def ach
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @pending = params[:pending] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.ach_transfers.includes(:event)
    else
      relation = AchTransfer.includes(:event)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount = ? or amount = ?", @q, -@q)
      else
        case @q.delete(" ")
        when ">0", ">=0"
          relation = relation.where("amount >= 0")
        when "<0", "<=0"
          relation = relation.where("amount <= 0")
        else
          relation = relation.search_recipient(@q)
        end
      end
    end

    relation = relation.pending if @pending

    @count = relation.count
    @ach_transfers = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def ach_start_approval
    @ach_transfer = AchTransfer.find(params[:id])

    render layout: "admin"
  end

  def ach_approve
    ach_transfer = AchTransferService::Approve.new(
      ach_transfer_id: params[:id],
      processor: current_user
    ).run

    redirect_to ach_start_approval_admin_path(ach_transfer), flash: { success: "Success" }
  rescue => e
    redirect_to ach_start_approval_admin_path(params[:id]), flash: { error: e.message }
  end

  def ach_reject
    ach_transfer = AchTransfer.find(params[:id])
    ach_transfer.mark_rejected!

    redirect_to ach_start_approval_admin_path(ach_transfer), flash: { success: "Success" }
  rescue => e
    redirect_to ach_start_approval_admin_path(params[:id]), flash: { error: e.message }
  end

  def disbursement_process
    @disbursement = Disbursement.find(params[:id])

    render layout: "admin"
  end

  def disbursement_approve
    disbursement = Disbursement.find(params[:id])

    disbursement.mark_approved!(current_user)

    redirect_to disbursement_process_admin_path(disbursement), flash: { success: "Success" }
  rescue => e
    notify_airbrake e
    redirect_to disbursement_process_admin_path(params[:id]), flash: { error: e.message }
  end

  def disbursement_reject
    disbursement = Disbursement.find(params[:id])

    disbursement.mark_rejected!(current_user)

    redirect_to disbursement_process_admin_path(disbursement), flash: { success: "Success" }
  rescue => e
    notify_airbrake e
    redirect_to disbursement_process_admin_path(params[:id]), flash: { error: e.message }
  end

  def check
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @in_transit = params[:in_transit] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.checks.includes(lob_address: :event)
    else
      relation = Check.includes(lob_address: :event)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount = ? or amount = ?", @q, -@q)
      else
        case @q.delete(" ")
        when ">0", ">=0"
          relation = relation.where("amount >= 0")
        when "<0", "<=0"
          relation = relation.where("amount <= 0")
        else
          relation = relation.search_recipient(@q)
        end
      end
    end

    relation = relation.in_transit if @in_transit

    @count = relation.count
    @checks = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def check_process
    @check = Check.find(params[:id])

    render layout: "admin"
  end

  def check_positive_pay_csv
    @check = Check.find(params[:id])

    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=check-#{@check.id}-#{@check.check_number}.csv"
    headers["X-Accel-Buffering"] = "no"
    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")

    response.status = 200

    self.response_body = ::CheckService::PositivePay::Csv.new(check_id: @check.id).run
  end

  def check_send
    check = ::CheckService::Send.new(
      check_id: params[:id]
    ).run

    redirect_to check_process_admin_path(check), flash: { success: "Success" }
  end

  def check_mark_in_transit_and_processed
    check = CheckService::MarkInTransitAndProcessed.new(
      check_id: params[:id]
    ).run

    redirect_to check_process_admin_path(check), flash: { success: "Success" }
  rescue => e
    redirect_to check_process_admin_path(params[:id]), flash: { error: e.message }
  end

  def increase_checks
    @page = params[:page] || 1
    @per = params[:per] || 20
    @checks = IncreaseCheck.page(@page).per(@per).order(created_at: :desc)

    render layout: "admin"
  end

  def increase_check_process
    @check = IncreaseCheck.find(params[:id])

    render layout: "admin"
  end

  def partner_donations
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @deposited = params[:deposited] == "1" ? true : nil
    @in_transit = params[:in_transit] == "1" ? true : nil
    @pending = params[:pending] == "1" ? true : nil
    @not_unpaid = params[:not_unpaid] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)
      relation = @event.partner_donations.includes(:event)
    else
      relation = PartnerDonation.includes(:event)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i
        relation = relation.where("payout_amount_cents = ? or payout_amount_cents = ?", @q, -@q)
      else
        relation = relation.search_name(@q)
      end
    end

    relation = relation.deposited if @deposited
    relation = relation.in_transit if @in_transit
    relation = relation.pending if @pending
    relation = relation.not_unpaid if @not_unpaid

    @count = relation.count
    @partner_donations = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def donations
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @deposited = params[:deposited] == "1" ? true : nil
    @in_transit = params[:in_transit] == "1" ? true : nil
    @failed = params[:failed] == "1" ? true : nil
    @missing_payout = params[:missing_payout] == "1" ? true : nil
    @missing_fee_reimbursement = params[:missing_fee_reimbursement] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.donations.includes(:event)
    else
      relation = Donation.includes(:event)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount = ? or amount = ?", @q, -@q)
      else
        relation = relation.search_name(@q)
      end
    end

    relation = relation.deposited if @deposited
    relation = relation.in_transit if @in_transit
    relation = relation.failed if @failed
    relation = relation.missing_payout if @missing_payout
    relation = relation.missing_fee_reimbursement if @missing_fee_reimbursement

    @count = relation.count
    @donations = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def recurring_donations
    @active = params[:active] == "1" ? true : nil
    @canceled = params[:canceled] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    relation = RecurringDonation.includes(:event).where.not(stripe_status: [:incomplete, :incomplete_expired])

    relation = relation.active if @active
    relation = relation.canceled if @canceled

    relation = relation.where(event_id: @event_id) if @event_id

    @donations = relation.page(params[:page]).per(20).order(created_at: :desc)

    render layout: "admin"
  end

  def disbursements
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @reviewing = params[:reviewing] == "1" ? true : nil
    @pending = params[:pending] == "1" ? true : nil
    @processing = params[:processing] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.disbursements.includes(:event)
    else
      relation = Disbursement.includes(:event)
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount = ? or amount = ?", @q, -@q)
      else
        relation = relation.search_name(@q)
      end
    end

    relation = relation.pending if @pending
    relation = relation.reviewing if @reviewing
    relation = relation.processing if @processing

    @count = relation.count
    @disbursements = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def disbursement_new
    render layout: "admin"
  end

  def disbursement_create
    ::DisbursementService::Create.new(
      source_event_id: params[:source_event_id],
      destination_event_id: params[:event_id],
      name: params[:name],
      amount: params[:amount],
      requested_by_id: current_user.id
    ).run

    redirect_to disbursements_admin_index_path, flash: { success: "Success" }
  rescue => e
    redirect_to disbursement_new_admin_index_path, flash: { error: e.message }
  end

  def hcb_codes
    @params = params.permit(:page, :per, :q, :has_receipt, :start_date, :end_date)
    @page = @params[:page] || 1
    @per = @params[:per] || 20
    @q = @params[:q].present? ? @params[:q] : nil
    @has_receipt = @params[:has_receipt]
    @start_date = @params[:start_date]
    @end_date = @params[:end_date]

    relation = HcbCode

    relation = relation.where("hcb_code ilike '%#{@q}%'") if @q
    relation = relation.missing_receipt if @has_receipt == "no"
    relation = relation.has_receipt_or_marked_no_or_lost if @has_receipt == "yes"
    relation = relation.lost_receipt if @has_receipt == "lost"

    begin
      relation = relation.where("hcb_codes.created_at >= ?", Date.strptime(@start_date, "%Y-%m-%d").beginning_of_day) if @start_date.present?
      relation = relation.where("hcb_codes.created_at <= ?", Date.strptime(@end_date, "%Y-%m-%d").end_of_day) if @end_date.present?
    rescue Date::Error
      flash[:error] = "Invalid date."
    end

    @count = relation.count
    @hcb_codes = relation.order("hcb_codes.created_at desc")

    respond_to do |format|
      format.html do
        @hcb_codes = @hcb_codes.page(@page).per(@per)
        render layout: "admin"
      end
      format.csv { render csv: @hcb_codes }
    end
  end

  def invoices
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @open = params[:open] == "1" ? true : nil
    @paid = params[:paid] == "1" ? true : nil
    @missing_payout = params[:missing_payout] == "1" ? true : nil
    @missing_fee_reimbursement = params[:missing_fee_reimbursement] == "1" ? true : nil
    @past_due = params[:past_due] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.invoices
    else
      relation = Invoice
    end

    if @q
      if @q.to_f != 0.0
        @q = (@q.to_f * 100).to_i

        relation = relation.where("amount_due = ? or amount_due = ?", @q, -@q)
      else
        relation = relation.search_description(@q)
      end
    end

    relation = relation.open_v2 if @open
    relation = relation.paid_v2 if @paid
    relation = relation.missing_payout if @missing_payout
    relation = relation.missing_fee_reimbursement if @missing_fee_reimbursement
    relation = relation.past_due if @past_due

    @count = relation.count
    @invoices = relation.page(@page).per(@per).order(created_at: :desc)

    render layout: "admin"
  end

  def invoice_process
    @invoice = Invoice.find(params[:id])

    render layout: "admin"
  end

  def invoice_mark_paid
    @invoice = Invoice.open.find(params[:id])

    ::InvoiceService::MarkPaid.new(
      invoice_id: @invoice.id,
      reason: params[:reason],
      attachment: params[:attachment],
      user: current_user
    ).run

    redirect_to invoices_admin_index_path, flash: { success: "Success" }
  end

  def sponsors
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.sponsors
    else
      relation = Sponsor
    end

    relation = relation.search_name(@q) if @q

    @count = relation.count
    @sponsors = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def google_workspaces
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
    @needs_ops_review = params[:needs_ops_review] == "1" ? true : nil
    @configuring = params[:configuring] == "1" ? true : nil

    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.g_suites
    else
      relation = GSuite.includes(:event)
    end

    relation = relation.search_domain(@q) if @q
    relation = relation.needs_ops_review if @needs_ops_review
    relation = relation.configuring if @configuring

    @count = relation.count
    @g_suites = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def google_workspace_process
    @g_suite = GSuite.find(params[:id])

    render layout: "admin"
  end

  def transaction_csvs
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil

    relation = TransactionCsv

    @count = relation.count
    @transaction_csvs = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def upload
    attrs = {
      file: params[:file]
    }
    transaction_csv = TransactionCsv.create!(attrs)

    ::TransactionEngineJob::TransactionCsvUpload.perform_later(transaction_csv.id)

    redirect_to transaction_csvs_admin_index_path, flash: { success: "CSV Uploaded" }
  end

  def google_workspace_approve
    @g_suite = GSuite.find(params[:id])

    has_existing_key = @g_suite.verification_key.present?

    GSuiteJob::SetVerificationKey.perform_later(@g_suite.id)

    redirect_to google_workspace_process_admin_path(@g_suite), flash: { success: "#{has_existing_key ? 'Updated verification key' : 'Approved'} (it may take a few seconds for the dashboard to reflect this change)" }
  end

  def google_workspace_update
    @g_suite = GSuite.find(params[:id])

    @g_suite = GSuiteService::Update.new(
      g_suite_id: @g_suite.id,
      domain: @g_suite.domain,
      verification_key: params[:verification_key],
      dkim_key: params[:dkim_key]
    ).run

    redirect_to google_workspace_process_admin_path(@g_suite), flash: { success: "Success" }
  end

  def set_event
    @canonical_transaction = ::CanonicalTransactionService::SetEvent.new(canonical_transaction_id: params[:id], event_id: params[:event_id], user: current_user).run

    redirect_to transaction_admin_path(@canonical_transaction)
  rescue => e
    redirect_to transaction_admin_path(params[:id]), flash: { error: e.message }
  end

  def audit
    @topups = StripeService::Topup.list[:data]
  end

  def bookkeeping
  end

  def balances
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

    if @start_date && @end_date && @start_date > @end_date
      flash[:info] = "Do you really want the Start Date to be after the End Date?"
    end

    relation = filtered_events.reorder("events.id asc")
    # Omit orgs if they were created after the end date
    relation = relation.where("events.created_at <= ?", @end_date) if @end_date

    @events = relation

    render_balance = ->(event, type) {
      ApplicationController.helpers.render_money(event.send(type, start_date: @start_date, end_date: @end_date))
    }
    template = [
      # Must be wrapped in lambdas
      [:organization_id, ->(e) { e.id }],
      [:organization_name, ->(e) { e.name }],
      [:net_balance, ->(e) { render_balance.call(e, :settled_balance_cents) }],
      [:expenses, ->(e) { render_balance.call(e, :settled_outgoing_balance_cents) }],
      [:revenue, ->(e) { render_balance.call(e, :settled_incoming_balance_cents) }],
      [:start_date, ->(_) { @start_date }],
      [:end_date, ->(_) { @end_date }]
    ]
    serializer = ->(event) do
      template.to_h.transform_values do |field|
        field.call(event)
      end
    end

    @data = @events.map { |event| serializer.call(event) }
    header_syms = template.transpose.first
    @headers = header_syms.map { |h| h.to_s.titleize(keep_id_suffix: true) }
    @rows = @data.map { |d| d.values }
    @count = @rows.count

    respond_to do |format|
      format.html do
        render layout: "admin"
      end

      filename = "balances_#{Time.now.strftime("%Y_%m_%d %H_%M_%S")}"

      format.csv do
        require "csv"

        csv = Enumerator.new do |y|
          y << ::CSV::Row.new(header_syms, @headers, true).to_s

          @rows.each do |row|
            y << ::CSV::Row.new(header_syms, row).to_s
          end
        end

        stream_data("text/csv", "#{filename}.csv", csv)
      end

      format.json do
        stream_data("application/json", "#{filename}.json", @data.to_json, false)
      end

    end
  end

  def grants
    @page = params[:page] || 1
    @per = params[:per] || 20
    @grants = Grant.includes(:event, :recipient).page(@page).per(@per).order(created_at: :desc)

    render layout: "admin"
  end

  def grant_process
    @grant = Grant.find(params[:id])

    render layout: "admin"
  end

  private

  def stream_data(content_type, filename, data, download = true)
    headers["Content-Type"] = content_type
    headers["Content-disposition"] = "#{download ? 'attachment; ' : ''}filename=#{filename}"
    headers["X-Accel-Buffering"] = "no"
    headers.delete("Content-Length")

    response.status = 200
    self.response_body = data
  end

  def filtered_events(events: Event.all)
    @q = params[:q].present? ? params[:q] : nil
    @demo_mode = params[:demo_mode].present? ? params[:demo_mode] : "full" # full accounts only by default
    @pending = params[:pending] == "0" ? nil : true # checked by default
    @unapproved = params[:unapproved] == "0" ? nil : true # checked by default
    @approved = params[:approved] == "0" ? nil : true # checked by default
    @rejected = params[:rejected] == "0" ? nil : true # checked by default
    @transparent = params[:transparent].present? ? params[:transparent] : "both" # both by default
    @omitted = params[:omitted].present? ? params[:omitted] : "both" # both by default
    @funded = params[:funded].present? ? params[:funded] : "both" # both by default
    @hidden = params[:hidden].present? ? params[:hidden] : "both" # both by default
    @organized_by = params[:organized_by].presence || "anyone"
    if params[:category] == "none"
      @category = "none"
    else
      @category = params[:category].present? ? params[:category] : "all"
    end
    @point_of_contact_id = params[:point_of_contact_id].present? ? params[:point_of_contact_id] : "all"
    if params[:country] == 9999.to_s
      @country = 9999
    else
      @country = params[:country].present? ? params[:country] : "all"
    end
    @activity_since_date = params[:activity_since]

    relation = events

    relation = relation.search_name(@q) if @q
    relation = relation.transparent if @transparent == "transparent"
    relation = relation.not_transparent if @transparent == "not_transparent"
    relation = relation.omitted if @omitted == "omitted"
    relation = relation.not_omitted if @omitted == "not_omitted"
    relation = relation.hidden if @hidden == "hidden"
    relation = relation.not_hidden if @hidden == "not_hidden"
    relation = relation.funded if @funded == "funded"
    relation = relation.not_funded if @funded == "not_funded"
    relation = relation.organized_by_hack_clubbers if @organized_by == "hack_clubbers"
    relation = relation.where(organized_by_teenagers: true).or(relation.where(organized_by_hack_clubbers: true)) if @organized_by == "teenagers"
    relation = relation.where.not(organized_by_hack_clubbers: true).and(relation.where.not(organized_by_teenagers: true)) if @organized_by == "adults"
    relation = relation.demo_mode if @demo_mode == "demo"
    relation = relation.not_demo_mode if @demo_mode == "full"
    relation = relation.joins(:canonical_transactions).where("canonical_transactions.date >= ?", @activity_since_date).group("events.id") if @activity_since_date.present?
    if @category == "none"
      relation = relation.where(category: nil)
    elsif @category != "all"
      relation = relation.where(category: @category)
    end
    relation = relation.where(point_of_contact_id: @point_of_contact_id) if @point_of_contact_id != "all"
    if @country == 9999
      relation = relation.where.not(country: "US")
    elsif @country != "all"
      relation = relation.where(country: @country)
    end

    states = []
    states << "pending" if @pending
    states << "unapproved" if @unapproved
    states << "approved" if @approved
    states << "rejected" if @rejected
    relation = relation.where("aasm_state in (?)", states)
  end

  include StaticPagesHelper # for airtable_info

  def airtable_task_size(task_name)
    info = airtable_info[task_name]
    res = HTTParty.get info[:url], query: { select: info[:query].to_json }
    case res.code
    when 200..399
      tasks = JSON.parse res.body
      tasks.size
    else # not successful
      return 9999 # return something invalidly high to get the ops team to report it
    end
  end

  def pending_task(task_name)
    @pending_tasks ||= {}
    @pending_tasks[task_name] ||= begin
      case task_name
      when :pending_hackathons_airtable
        airtable_task_size :hackathons
      when :pending_grant_airtable
        airtable_task_size :grant
      when :pending_bank_applications_airtable
        airtable_task_size :bank_applications
      when :pending_onboard_id_airtable
        airtable_task_size :onboard_id
      when :pending_stickermule_airtable
        airtable_task_size :stickermule
      when :pending_stickers_airtable
        airtable_task_size :stickers
      when :pending_wallets_airtable
        airtable_task_size :wallets
      when :pending_replit_airtable
        airtable_task_size :replit
      when :pending_sendy_airtable
        airtable_task_size :sendy
      when :pending_onepassword_airtable
        airtable_task_size :onepassword
      when :pending_domains_airtable
        airtable_task_size :domains
      when :pending_pvsa_airtable
        airtable_task_size :pvsa
      when :pending_theeventhelper_airtable
        airtable_task_size :theeventhelper
      when :pending_first_grant_airtable
        airtable_task_size :first_grant
      when :pending_wire_transfers_airtable
        airtable_task_size :wire_transfers
      when :pending_paypal_transfers_airtable
        airtable_task_size :paypal_transfers
      when :pending_disputed_transactions_airtable
        airtable_task_size :disputed_transactions
      when :pending_feedback_airtable
        airtable_task_size :feedback
      when :emburse_card_requests
        EmburseCardRequest.under_review.size
      when :emburse_transactions
        EmburseTransaction.under_review.size
      when :checks
        # Check.pending.size + Check.unfinished_void.size
        0
      when :ach_transfers
        AchTransfer.pending.size
      when :pending_fees
        Event.pending_fees.size
      when :negative_events
        Event.negatives.size
      when :fee_reimbursements
        FeeReimbursement.unprocessed.size
      when :emburse_transfers
        EmburseTransfer.under_review.size
      when :g_suite_accounts
        GSuiteAccount.under_review.size
      when :transactions
        Transaction.needs_action.size
      when :disbursements
        Disbursement.pending.size
      when :organizer_position_deletion_requests
        OrganizerPositionDeletionRequest.under_review.size
      else
        # failed to get task size
      end
    end

    @pending_tasks[task_name]
  end

  def pending_tasks
    # This method could take upwards of 10 seconds. USE IT SPARINGLY
    pending_task :pending_hackathons_airtable
    pending_task :pending_grant_airtable
    pending_task :pending_bank_applications_airtable
    pending_task :pending_onboard_id_airtable
    pending_task :pending_stickermule_airtable
    pending_task :pending_stickers_airtable
    pending_task :pending_wallets_airtable
    pending_task :pending_replit_airtable
    pending_task :pending_sendy_airtable
    pending_task :pending_onepassword_airtable
    pending_task :pending_domains_airtable
    pending_task :pending_pvsa_airtable
    pending_task :pending_theeventhelper_airtable
    pending_task :pending_first_grant_airtable
    pending_task :pending_feedback_airtable
    pending_task :wire_transfers
    pending_task :paypal_transfers
    pending_task :disputed_transactions_airtable
    pending_task :emburse_card_requests
    pending_task :checks
    pending_task :ach_transfers
    pending_task :pending_fees
    pending_task :negative_events
    pending_task :fee_reimbursements
    pending_task :emburse_transfers
    pending_task :emburse_transactions
    pending_task :g_suite_accounts
    pending_task :transactions
    pending_task :disbursements
    pending_task :organizer_position_deletion_requests

    @pending_tasks
  end

end
