# frozen_string_literal: true

class StatsController < ApplicationController
  skip_after_action :verify_authorized
  skip_before_action :signed_in_user

  def project_stats
    slug = params[:slug]

    event = Event.find_by(is_public: true, slug:)

    return render plain: "404 Not found", status: 404 unless event

    raised = event.canonical_transactions.revenue.sum(:amount_cents)

    render json: {
      raised:
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

  def admin_receipt_stats # secret api endpoint for the tv in the bank office
    users = [
      2189, # Caleb
      2046, # Mel
      2455, # Liv
      892,  # Max
      4059, # Daisy
      3851, # Arianna
      2232  # Sam
    ]

    q = <<~SQL
      SELECT
        id,
        (
            SELECT COUNT(*) FROM hcb_codes
            INNER JOIN canonical_pending_transactions cpt ON cpt.hcb_code = hcb_codes.hcb_code
            INNER JOIN raw_pending_stripe_transactions rpst ON cpt.raw_pending_stripe_transaction_id = rpst.id
            INNER JOIN stripe_cardholders sc ON sc.stripe_id = rpst.stripe_transaction->'card'->'cardholder'->>'id'
            LEFT JOIN receipts ON receipts.receiptable_type = 'HcbCode' AND receipts.receiptable_id = hcb_codes.id
            LEFT JOIN canonical_pending_declined_mappings cpdm ON cpdm.canonical_pending_transaction_id = cpt.id
            WHERE sc.user_id = users.id
            AND   receipts.id IS NULL AND cpdm.id IS NULL AND hcb_codes.marked_no_or_lost_receipt_at IS NULL
        )
      FROM users
      WHERE id IN (?)
      ORDER BY count DESC;
    SQL

    render json: User.find_by_sql([q, users])
  end

end
