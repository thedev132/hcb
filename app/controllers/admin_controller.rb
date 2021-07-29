# frozen_string_literal: true

class AdminController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin

  layout "application"

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
    render json: { elapsed: elapsed, size: size }, status: 200
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

  def transaction_dedupe
    @groups = TransactionEngine::HashedTransactionService::GroupedDuplicates.new.run
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
    @q = params[:q].present? ? params[:q] : nil
    @pending = params[:pending] == "0" ? nil : true # checked by default
    @unapproved = params[:unapproved] == "0" ? nil : true # checked by default
    @approved = params[:approved] == "0" ? nil : true # checked by default
    @rejected = params[:rejected] == "0" ? nil : true # checked by default
    @transparent = params[:transparent].present? ? params[:transparent] : nil
    @omitted = params[:omitted].present? ? params[:omitted] : nil
    @hidden = params[:hidden].present? ? params[:hidden] : nil

    relation = Event.not_partner

    relation = relation.search_name(@q) if @q
    relation = relation.transparent if @transparent == "transparent"
    relation = relation.not_transparent if @transparent == "not_transparent"
    relation = relation.omitted if @omitted == "omitted"
    relation = relation.not_omitted if @omitted == "not_omitted"
    relation = relation.hidden if @hidden == "hidden"
    relation = relation.not_hidden if @hidden == "not_hidden"

    states = []
    states << "pending" if @pending
    states << "unapproved" if @unapproved
    states << "approved" if @approved
    states << "rejected" if @rejected
    relation = relation.where("aasm_state in (?)", states)

    @count = relation.count

    @events = relation.page(@page).per(@per).reorder("created_at desc")

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

    attrs = {
      name: params[:name],
      emails: emails,
      has_fiscal_sponsorship_document: params[:has_fiscal_sponsorship_document].to_i == 1 ? true : false,
      sponsorship_fee: params[:sponsorship_fee]
    }
    ::EventService::Create.new(attrs).run

    redirect_to events_admin_index_path, flash: { success: "Success" }
  rescue => e
    redirect_to event_new_admin_index_path, flash: { error: e.message }
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

    @users = relation.page(@page).per(@per).order("created_at desc")

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
    attrs = {
      unique_bank_identifier: params[:unique_bank_identifier],
      date: params[:date],
      memo: params[:memo],
      amount: params[:amount]
    }
    ::RawCsvTransactionService::Create.new(attrs).run

    redirect_to raw_transactions_admin_index_path, flash: { success: "Success" }
  rescue => e
    redirect_to raw_transaction_new_admin_index_path, flash: { error: e.message }
  end

  def hashed_transactions
    @page = params[:page] || 1
    @per = params[:per] || 100
    @possible_duplicates = params[:possible_duplicates] == "1" ? true : nil
    @uncanonized = params[:uncanonized] == "1" ? true : nil
    @unique_bank_identifier = params[:unique_bank_identifier].present? ? params[:unique_bank_identifier] : nil

    relation = HashedTransaction
    relation = relation.possible_duplicates if @possible_duplicates
    relation = relation.uncanonized if @uncanonized
    relation = relation.where(unique_bank_identifier: @unique_bank_identifier) if @unique_bank_identifier

    @count = relation.count

    @hashed_transactions = relation.page(@page).per(@per).order("date desc, primary_hash asc")

    render layout: "admin"
  end

  def ledger
    @page = params[:page] || 1
    @per = params[:per] || 100
    @q = params[:q].present? ? params[:q] : nil
    @unmapped = params[:unmapped] == "1" ? true : nil
    @exclude_top_ups = params[:exclude_top_ups] == "1" ? true : nil
    @mapped_by_human = params[:mapped_by_human] == "1" ? true : nil
    @event_id = params[:event_id].present? ? params[:event_id] : nil

    if @event_id
      @event = Event.find(@event_id)

      relation = @event.canonical_transactions.includes(:canonical_event_mapping)
    else
      relation = CanonicalTransaction.includes(:canonical_event_mapping)
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

    relation = relation.unmapped if @unmapped
    relation = relation.not_stripe_top_up if @exclude_top_ups
    relation = relation.mapped_by_human if @mapped_by_human

    @count = relation.count

    @canonical_transactions = relation.page(@page).per(@per).order("date desc")

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
    attrs = {
      ach_transfer_id: params[:id],
      scheduled_arrival_date: params[:scheduled_arrival_date],
      confirmation_number: params[:confirmation_number]
    }
    ach_transfer = AchTransferService::Approve.new(attrs).run

    redirect_to ach_start_approval_admin_path(ach_transfer), flash: { success: "Success" }
  rescue => e
    redirect_to ach_start_approval_admin_path(params[:id]), flash: { error: e.message }
  end

  def ach_reject
    attrs = {
      ach_transfer_id: params[:id],
    }
    ach_transfer = AchTransferService::Reject.new(attrs).run

    redirect_to ach_start_approval_admin_path(ach_transfer), flash: { success: "Success" }
  rescue => e
    redirect_to ach_start_approval_admin_path(params[:id]), flash: { error: e.message }
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
    attrs = {
      check_id: params[:id]
    }
    check = ::CheckService::Send.new(attrs).run

    redirect_to check_process_admin_path(check), flash: { success: "Success" }
  end

  def check_mark_in_transit_and_processed
    attrs = {
      check_id: params[:id]
    }
    check = CheckService::MarkInTransitAndProcessed.new(attrs).run

    redirect_to check_process_admin_path(check), flash: { success: "Success" }
  rescue => e
    redirect_to check_process_admin_path(params[:id]), flash: { error: e.message }
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

  def disbursements
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil
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
    #relation = relation.processing if @processing # TODO: remove ruby logic from scope

    @count = relation.count
    @disbursements = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def disbursement_new
    render layout: "admin"
  end

  def disbursement_create
    attrs = {
      source_event_id: params[:source_event_id],
      destination_event_id: params[:event_id],
      name: params[:name],
      amount: params[:amount]
    }
    ::DisbursementService::Create.new(attrs).run

    redirect_to disbursements_admin_index_path, flash: { success: "Success" }
  rescue => e
    redirect_to disbursement_new_admin_index_path, flash: { error: e.message }
  end

  def hcb_codes
    @page = params[:page] || 1
    @per = params[:per] || 20
    @q = params[:q].present? ? params[:q] : nil

    relation = HcbCode

    relation = relation.where("hcb_code ilike '%#{@q}%'") if @q

    @count = relation.count
    @hcb_codes = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
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
    @invoices = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def invoice_process
    @invoice = Invoice.find(params[:id])

    render layout: "admin"
  end

  def invoice_mark_paid
    @invoice = Invoice.open.find(params[:id])

    attrs = {
      invoice_id: @invoice.id,
      reason: params[:reason],
      attachment: params[:attachment],
      user: current_user
    }
    ::InvoiceService::MarkPaid.new(attrs).run

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


  def google_workspace_approve
    @g_suite = GSuite.find(params[:id])

    has_existing_key = @g_suite.verification_key.present?

    GSuiteJob::SetVerificationKey.perform_later(@g_suite.id)

    redirect_to google_workspace_process_admin_path(@g_suite), flash: { success: "#{has_existing_key ? 'Updated verification key' : 'Approved'} (it may take a few seconds for the dashboard to reflect this change)" }
  end

  def google_workspace_update
    @g_suite = GSuite.find(params[:id])

    attrs = {
      g_suite_id: @g_suite.id,
      domain: @g_suite.domain,
      verification_key: params[:verification_key],
      dkim_key: params[:dkim_key]
    }
    @g_suite = GSuiteService::Update.new(attrs).run

    redirect_to google_workspace_process_admin_path(@g_suite), flash: { success: "Success" }
  end

  def set_event
    @canonical_transaction = ::CanonicalTransactionService::SetEvent.new(canonical_transaction_id: params[:id], event_id: params[:event_id], user: current_user).run

    redirect_to transaction_admin_path(@canonical_transaction)
  end

  def audit
    @topups = StripeService::Topup.list[:data]
  end

  def bookkeeping
  end

  private

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
      when :pending_stickermule_airtable
        airtable_task_size :stickermule
      when :pending_replit_airtable
        airtable_task_size :replit
      when :pending_sendy_airtable
        airtable_task_size :sendy
      when :pending_pvsa_airtable
        airtable_task_size :pvsa
      when :wire_transfers
        airtable_task_size :wire_transfers
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
    pending_task :pending_stickermule_airtable
    pending_task :pending_replit_airtable
    pending_task :pending_sendy_airtable
    pending_task :pending_pvsa_airtable
    pending_task :wire_transfers
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
