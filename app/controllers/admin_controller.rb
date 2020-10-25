class AdminController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin

  def tasks
    @active = pending_tasks
    @pending_actions = @active.values.any? { |e| e.nonzero? }
    @blankslate_message = [
      "You look great today, #{current_user.first_name}.",
      "You’re a *credit* to your team, #{current_user.first_name}.",
      "Everybody thinks you’re amazing, #{current_user.first_name}.",
      "You’re every organizer’s favorite point of contact.",
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

  def audit
    @topups = StripeService::Topup.list[:data]
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
