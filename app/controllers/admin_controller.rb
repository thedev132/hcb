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

  def pending_fees
    @pending_fees = Event.pending_fees
    @pending_fees_v2 = Event.pending_fees_v2
  end

  def export_pending_fees
    csv = StaticPageService::ExportPendingFees.new.run

    send_data csv, filename: "#{Date.today}_pending_fees.csv"
  end

  def pending_disbursements
    @pending_disbursements = Disbursement.pending

    authorize @pending_disbursements
  end

  def export_pending_disbursements
    authorize Disbursement

    disbursements = Disbursement.pending

    attributes = %w{memo amount}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes.map

      disbursements.each do |dsb|
        csv << attributes.map do |attr|
          if attr == 'memo'
            dsb.transaction_memo
          else
            dsb.amount.to_f / 100
          end
        end
      end
    end

    send_data result, filename: "Pending Disbursements #{Date.today}.csv"
  end

  def search
    # allows the same URL to easily be used for form and GET
    return if request.method == 'GET'

    # removing dashes to deal with phone number
    query = params[:q].gsub('-', '').strip

    users = []

    users.push(User.where("full_name ilike ?", "%#{query.downcase}%").includes(:events) )
    users.push(User.where(email: query).includes(:events))
    users.push(User.where(phone_number: query).includes(:events))

    @result = users.flatten.compact
  end

  def negative_events
    @negative_events = Event.negatives
  end

  def transaction_unmapped_show
    @canonical_transaction = CanonicalTransaction.find(params[:id])

    @canonical_pending_transactions = CanonicalPendingTransaction.unmapped.where(amount_cents: @canonical_transaction.amount_cents)

    render layout: "admin"
  end

  def transaction_dedupe
    @groups = TransactionEngine::HashedTransactionService::GroupedDuplicates.new.run
  end

  def transaction_pending_unsettled
    @canonical_pending_transactions = CanonicalPendingTransaction.unsettled.order("date desc")
  end

  def events
    @page = params[:page] || 1
    @per = params[:per] || 500
    @q = params[:q].present? ? params[:q] : nil
    @pending = params[:pending] == "1" ? true : nil
    @transparent = params[:transparent] == "1" ? true : nil
    @omitted = params[:omitted] == "1" ? true : nil
    @hidden = params[:hidden] == "1" ? true : nil

    relation = Event

    relation = relation.search_name(@q) if @q
    relation = relation.pending if @pending
    relation = relation.transparent if @transparent
    relation = relation.omitted if @omitted
    relation = relation.hidden if @hidden

    @count = relation.count

    @events = relation.page(@page).per(@per).reorder("created_at desc")

    render layout: "admin"
  end

  def event_process
    @event = Event.find(params[:id])

    render layout: "admin"
  end

  def ledger
    @page = params[:page] || 1
    @per = params[:per] || 500
    @q = params[:q].present? ? params[:q] : nil
    @unmapped = params[:unmapped] == "1" ? true : nil
    @exclude_top_ups = params[:exclude_top_ups] == "1" ? true : nil
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

    @count = relation.count

    @canonical_transactions = relation.page(@page).per(@per).order("date desc")

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
      scheduled_arrival_date: params[:scheduled_arrival_date]
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
    @succeeded = params[:succeeded] == "1" ? true : nil
    @exclude_requires_payment_method = params[:exclude_requires_payment_method] == "1" ? true : nil

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

    relation = relation.succeeded if @succeeded
    relation = relation.exclude_requires_payment_method if @exclude_requires_payment_method

    @count = relation.count
    @donations = relation.page(@page).per(@per).order("created_at desc")

    render layout: "admin"
  end

  def set_event
    @canonical_transaction = ::CanonicalTransactionService::SetEvent.new(canonical_transaction_id: params[:id], event_id: params[:event_id]).run

    redirect_to transaction_unmapped_show_path(@canonical_transaction)
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
