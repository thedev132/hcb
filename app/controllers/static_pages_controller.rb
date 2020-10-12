require 'net/http'

class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:stats, :branding, :faq]
  before_action :signed_in_admin, except: [:stats, :branding, :faq, :index, :my_cards, :my_inbox, :my_stripe_authorizations_list]

  def index
    if signed_in?
      attrs = {
        current_user: current_user
      }
      @service = StaticPageService::Index.new(attrs)

      @events = @service.events
      @invites = @service.invites
    end
    if admin_signed_in?
      @transaction_volume = Transaction.total_volume
    end
  end

  def admin_tasks
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

  def admin_task_size
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

  def branding
    @logos = [
      { name: 'Original Light', criteria: 'For white or light colored backgrounds.', background: 'smoke' },
      { name: 'Original Dark', criteria: 'For black or dark colored backgrounds.', background: 'black' },
      { name: 'Outlined Black', criteria: 'For white or light colored backgrounds.', background: 'snow' },
      { name: 'Outlined White', criteria: 'For black or dark colored backgrounds.', background: 'black' }
    ]
    @event_name = signed_in? && current_user.events.first ? current_user.events.first.name : 'Hack Pennsylvania'
  end

  def search
    # allows the same URL to easily be used for form and GET
    return if request.method == 'GET'

    # removing dashes to deal with phone number
    query = params[:q].gsub('-', '').strip

    users = []

    users.push(User.where("full_name ilike ?", "%#{query.downcase}%"))
    users.push(User.where(email: query))
    users.push(User.where(phone_number: query))

    @result = users.flatten.compact
  end

  def faq
  end

  def negative_events
    @negative_events = Event.negatives
  end

  def my_cards
    flash[:success] = 'Card activated!' if params[:activate]
    @stripe_cards = current_user.stripe_cards.includes(:event)
    @emburse_cards = current_user.emburse_cards.includes(:event)
  end

  # async frame
  def my_stripe_authorizations_list
    @stripe_cards = current_user.stripe_cards.includes(:event, stripe_authorizations: :receipts)
    @authorizations = current_user.stripe_authorizations.includes(stripe_card: :event).awaiting_receipt.limit(5)
    render :my_stripe_authorizations_list, layout: false
  end

  def my_inbox
    @authorizations = current_user.stripe_authorizations.includes(stripe_card: :event).awaiting_receipt
    @transactions = current_user.emburse_transactions.includes(emburse_card: :event).awaiting_receipt
    @txs = @authorizations + @transactions
    @count = @txs.size
  end

  def stats
    now = params[:date].present? ? Date.parse(params[:date]) : DateTime.current
    year_ago = now - 1.year
    qtr_ago = now - 3.month
    month_ago = now - 1.month

    events_list = []
    Event.where('created_at <= ?', now).order(created_at: :desc).limit(10).each { |event|
      events_list.push({
        created_at: event.created_at.to_i, # unix timestamp
      })
    }

    # NOTE: These stats are consumed by the hackclub/goblin
    # slack bot, and modifying the JSON schema without updating the bot
    # MAY BREAK THE BOT. - @thesephist
    render json: {
      date: now,
      transactions_volume: Transaction.where('transactions.created_at <= ?', now).total_volume,
      transactions_count: Transaction.where('created_at <= ?', now).size,
      events_count: Event.where('created_at <= ?', now).size,
      # Transactions are sorted by date DESC by default, so first one is... chronologically last
      last_transaction_date: Transaction.where('created_at <= ?', now).first.created_at.to_i,
      raised: Transaction.raised_during(DateTime.strptime('0', '%s'), now),
      last_year: {
        transactions_volume: Transaction.volume_during(year_ago, now),
        revenue: Transaction.revenue_during(year_ago, now),
        raised: Transaction.raised_during(year_ago, now),
      },
      last_qtr: {
        transactions_volume: Transaction.volume_during(qtr_ago, now),
        revenue: Transaction.revenue_during(qtr_ago, now),
        raised: Transaction.raised_during(qtr_ago, now),
      },
      last_month: {
        transactions_volume: Transaction.volume_during(month_ago, now),
        revenue: Transaction.revenue_during(month_ago, now),
        raised: Transaction.raised_during(month_ago, now),
      },
      events: events_list,
    }
  end

  private

  def link_to_airtable_task(task_name)
    airtable_info[task_name][:destination]
  end
  helper_method :link_to_airtable_task

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

  def airtable_info
    {
      hackathons: {
        url: "https://api2.hackclub.com/v0.1/hackathons.hackclub.com/applications",
        query: { filterByFormula: "AND(Approved=0,Rejected=0)", fields: [] } ,
        destination: "https://airtable.com/tblYVTFLwY378YZa4/viwpJOp6ZmMDfcbgb"
      },
      grant: {
        url: "https://api2.hackclub.com/v0.1/Bank%20Promotions/Github%20Grant",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblsYQ54Rg1Pjz1xP/viwjETKo05TouqYev"
      },
      stickermule: {
        url: "https://api2.hackclub.com/v0.1/Bank%20Promotions/StickerMule",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblwYTdp2fiBv7JqA/viwET9tCYBwaZ3NIq"
      },
      replit: {
        url: "https://api2.hackclub.com/v0.1/Bank%20Promotions/Repl.it%20Hacker%20Plan",
        query: {filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl6cbpdId4iA96mD/viw2T8d98ZhhacHCf"
      },
      sendy: {
        url: "https://api2.hackclub.com/v0.1/Bank%20Promotions/Sendy",
        query: {filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl1MRaNpF4KphbOd/viwdGjjDdtsS7bjlP"
      },
      wire_transfers: {
        url: "https://api2.hackclub.com/v0.1/Bank%20Promotions/Wire%20Transfers",
        query: {filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbloFbH16HI7t3mfG/viwzgt8VLHOC82m8n"
      },
    }
  end
end
