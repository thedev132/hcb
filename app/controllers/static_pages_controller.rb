require 'net/http'

class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:stats, :project_stats, :branding, :faq]

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

  def branding
    @logos = [
      { name: 'Original Light', criteria: 'For white or light colored backgrounds.', background: 'smoke' },
      { name: 'Original Dark', criteria: 'For black or dark colored backgrounds.', background: 'black' },
      { name: 'Outlined Black', criteria: 'For white or light colored backgrounds.', background: 'snow' },
      { name: 'Outlined White', criteria: 'For black or dark colored backgrounds.', background: 'black' }
    ]
    @event_name = signed_in? && current_user.events.first ? current_user.events.first.name : 'Hack Pennsylvania'
  end

  def faq
  end

  def my_cards
    flash[:success] = 'Card activated!' if params[:activate]
    @stripe_cards = current_user.stripe_cards.includes(:event)
    @emburse_cards = current_user.emburse_cards.includes(:event)
  end

  # async frame
  def my_stripe_authorizations_list
    @authorizations = current_user.stripe_authorizations.includes(stripe_card: :event).awaiting_receipt.limit(5)
    if @authorizations.any?
      render :my_stripe_authorizations_list, layout: !request.xhr?
    else
      head :ok
    end
  end

  def my_inbox
    @authorizations = current_user.stripe_authorizations.includes(stripe_card: :event).awaiting_receipt
    @transactions = current_user.emburse_transactions.includes(emburse_card: :event).awaiting_receipt
    @txs = @authorizations + @transactions
    @count = @txs.size
  end

  def project_stats
    slug = params[:slug]

    event = Event.find_by(is_public: true, slug: slug)

    return render plain: "404 Not found", status: 404 unless event

    raised = Event.canonical_transactions.revenue.sum(:amount)

    render json: {
      raised: raised
    }
  end

  def stats
    now = params[:date].present? ? Date.parse(params[:date]) : DateTime.current
    year_ago = now - 1.year
    qtr_ago = now - 3.month
    month_ago = now - 1.month

    events_list = Event.not_omitted
                       .where('created_at <= ?', now)
                       .order(created_at: :desc)
                       .limit(10)
                       .pluck(:created_at)
                       .map(&:to_i)
                       .map { |time| {created_at: time} }

    tx_all = CanonicalTransaction.included_in_stats.where('date <= ?', now)

    render json: {
      date: now,
      events_count: Event.not_omitted.where('created_at <= ?', now).size,
      last_transaction_date: tx_all.order(:date).last.date.to_time.to_i,

      # entire time period. this remains to prevent breaking changes to existing systems that use this endpoint
      raised: tx_all.revenue.sum(:amount_cents),
      transactions_count: tx_all.size,
      transactions_volume: tx_all.sum('@amount_cents'),

      # entire (all), year, quarter, and month time periods
      all: CanonicalTransactionService::Stats::During.new(end_time: now).run,
      last_year: CanonicalTransactionService::Stats::During.new(start_time: year_ago, end_time: now).run,
      last_qtr: CanonicalTransactionService::Stats::During.new(start_time: qtr_ago, end_time: now).run,
      last_month: CanonicalTransactionService::Stats::During.new(start_time: month_ago, end_time: now).run,

      # events
      events: events_list,
    }
  end

  def stripe_charge_lookup
    charge_id = params[:id]
    @payment = Invoice.find_by(stripe_charge_id: charge_id)

    # No invoice with that charge id? Maybe we can find a donation payment with that charge?
    # Donations don't store charge id, but they store payment intent, and we can link it with the charge's payment intent on stripe
    unless @payment
      payment_intent_id = StripeService::Charge.retrieve(charge_id)['payment_intent']
      @payment = Donation.find_by(stripe_payment_intent_id: payment_intent_id)
    end

    @event = @payment.event

    render json: {
      event_id: @event.id,
      event_name: @event.name,
      payment_type: @payment.class.name,
      payment_id: @payment.id
    }
  rescue StripeService::InvalidRequestError => e
    render json: {
      event_id: nil
    }
  end
end
