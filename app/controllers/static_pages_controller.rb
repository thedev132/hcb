# frozen_string_literal: true

require "net/http"

class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:stats, :stats_custom_duration, :project_stats, :branding, :faq]
  skip_before_action :redirect_to_onboarding, only: [:branding, :faq]

  def index
    if signed_in?
      attrs = {
        current_user: current_user
      }
      @service = StaticPageService::Index.new(attrs)

      @events = @service.events
      @organizer_positions = @service.organizer_positions.not_hidden
      @invites = @service.invites

      @show_event_reorder_tip = current_user.organizer_positions.where.not(sort_index: nil).none?
    end
    if admin_signed_in?
      @transaction_volume = CanonicalTransaction.included_in_stats.sum("@amount_cents")
    end
  end

  def branding
    @logos = [
      { name: "Original Light", criteria: "For white or light colored backgrounds.", background: "smoke" },
      { name: "Original Dark", criteria: "For black or dark colored backgrounds.", background: "black" },
      { name: "Outlined Black", criteria: "For white or light colored backgrounds.", background: "snow" },
      { name: "Outlined White", criteria: "For black or dark colored backgrounds.", background: "black" }
    ]
    @icons = [
      { name: "Icon Original", criteria: "The original Hack Club Bank logo.", background: "smoke" },
      { name: "Icon Dark", criteria: "Hack Club Bank logo in dark mode.", background: "black" }
    ]
    @event_name = signed_in? && current_user.events.first ? current_user.events.first.name : "Hack Pennsylvania"
  end

  def faq
  end

  def my_cards
    flash[:success] = "Card activated!" if params[:activate]
    @stripe_cards = current_user.stripe_cards.includes(:event)
    @emburse_cards = current_user.emburse_cards.includes(:event)
  end

  # async frame
  def my_missing_receipts_list
    @missing_receipt_ids = []

    current_user.stripe_cards.map do |card|
      card.hcb_codes.missing_receipt.each do |hcb_code|
        next unless hcb_code.receipt_required?

        @missing_receipt_ids << hcb_code.id
        break unless @missing_receipt_ids.size < 5
      end
    end
    @missing = HcbCode.where(id: @missing_receipt_ids)
    if @missing.any?
      render :my_missing_receipts_list, layout: !request.xhr?
    else
      head :ok
    end
  end

  # async frame
  def my_missing_receipts_icon
    @missing_receipt_count ||= begin
      count = 0

      stripe_cards = current_user.stripe_cards.includes(:event)
      emburse_cards = current_user.emburse_cards.includes(:event)

      (stripe_cards + emburse_cards).each do |card|
        card.hcb_codes.missing_receipt.each do |hcb_code|
          next unless hcb_code.receipt_required?

          count += 1
        end
      end

      count
    end

    render :my_missing_receipts_icon, layout: false
  end

  def my_inbox
    user_cards = current_user.stripe_cards + current_user.emburse_cards
    user_hcb_code_ids = user_cards.flat_map { |card| card.hcb_codes.pluck(:id) }
    user_hcb_codes = HcbCode.where(id: user_hcb_code_ids)

    hcb_codes_missing_ids = user_hcb_codes.missing_receipt.filter(&:receipt_required?).pluck(:id)
    hcb_codes_missing = HcbCode.where(id: hcb_codes_missing_ids).order(created_at: :desc)

    @count = hcb_codes_missing.count # Total number of HcbCodes missing receipts
    @hcb_codes = hcb_codes_missing.page(params[:page]).per(params[:per] || 20)

    @card_hcb_codes = @hcb_codes.group_by { |hcb| hcb.card.to_global_id.to_s }
    @cards = GlobalID::Locator.locate_many(@card_hcb_codes.keys)
    # Ideally we'd preload (includes) events for @cards, but that isn't
    # supported yet: https://github.com/rails/globalid/pull/139
  end

  def project_stats
    slug = params[:slug]

    event = Event.find_by(is_public: true, slug: slug)

    return render plain: "404 Not found", status: 404 unless event

    raised = event.canonical_transactions.revenue.sum(:amount_cents)

    render json: {
      raised: raised
    }
  end

  def stats_custom_duration
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : DateTime.new(2015, 1, 1)
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : DateTime.current

    render json: CanonicalTransactionService::Stats::During.new(start_time: start_date, end_time: end_date).run
  end

  def stats
    now = params[:date].present? ? Date.parse(params[:date]) : DateTime.current
    year_ago = now - 1.year
    qtr_ago = now - 3.month
    month_ago = now - 1.month
    week_ago = now - 1.week

    events_list = Event.not_omitted
                       .where("created_at <= ?", now)
                       .order(created_at: :desc)
                       .limit(10)
                       .pluck(:created_at)
                       .map(&:to_i)
                       .map { |time| { created_at: time } }

    tx_all = CanonicalTransaction.where.not("hcb_code LIKE 'HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::BANK_FEE_CODE}%'")
                                 .included_in_stats
                                 .where("date <= ?", now)

    pending_tx_all = CanonicalPendingTransaction.where(raw_pending_bank_fee_transaction_id: nil)
                                                .included_in_stats
                                                .unsettled
                                                .and(CanonicalPendingTransaction.outgoing.or(CanonicalPendingTransaction.fronted))

    render json: {
      date: now,
      events_count: Event.not_omitted
                         .not_hidden
                         .not_demo_mode
                         .approved
                         .where("created_at <= ?", now)
                         .count,
      last_transaction_date: tx_all.order(:date).last.date.to_time.to_i,

      # entire time period. this remains to prevent breaking changes to existing systems that use this endpoint
      raised: tx_all.revenue.sum(:amount_cents) + pending_tx_all.incoming.sum(:amount_cents),
      transactions_count: tx_all.size,
      transactions_volume: tx_all.sum("@amount_cents") + pending_tx_all.sum("@amount_cents"),

      # entire (all), year, quarter, and month time periods
      all: CanonicalTransactionService::Stats::During.new.run,
      last_year: CanonicalTransactionService::Stats::During.new(start_time: year_ago, end_time: now).run,
      last_qtr: CanonicalTransactionService::Stats::During.new(start_time: qtr_ago, end_time: now).run,
      last_month: CanonicalTransactionService::Stats::During.new(start_time: month_ago, end_time: now).run,
      last_week: CanonicalTransactionService::Stats::During.new(start_time: week_ago, end_time: now).run,

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
      payment_intent_id = StripeService::Charge.retrieve(charge_id)["payment_intent"]
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

  def feedback
    message = params[:message]
    share_email = params[:share_email] || "1"

    feedback = {
      "Share your idea(s)" => message,
    }

    if share_email == "1"
      feedback["Name"] = current_user.full_name
      feedback["Email"] = current_user.email
      feedback["Organization"] = current_user.events.first&.name
    end

    Feedback.create(feedback)

    head :no_content
  end

end
