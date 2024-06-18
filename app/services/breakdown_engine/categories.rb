# frozen_string_literal: true

module BreakdownEngine
  class Categories
    def initialize(event)
      @event = event
    end

    def run
      RawStripeTransaction.select(
        "trim(upper(split_part(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'category', '*', 1))) AS category",
        "SUM(raw_stripe_transactions.amount_cents) * -1 AS amount_cents"
      )
                          .joins("LEFT JOIN canonical_transactions ct ON raw_stripe_transactions.id = ct.transaction_source_id AND ct.transaction_source_type = 'RawStripeTransaction'")
                          .joins("LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id")
                          .where("event_mapping.event_id = ?", @event.id)
                          .group("category")
                          .order("amount_cents")
                          .limit(100)
                          .each_with_object({}) { |merchant, hash| hash[merchant[:category].truncate(55).humanize] = merchant[:amount_cents].to_f / 100 }
    end

  end
end
