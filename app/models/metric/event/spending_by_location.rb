# frozen_string_literal: true

# == Schema Information
#
# Table name: metrics
#
#  id           :bigint           not null, primary key
#  metric       :jsonb
#  subject_type :string
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_id   :bigint
#
# Indexes
#
#  index_metrics_on_subject  (subject_type,subject_id)
#
class Metric
  module Event
    class SpendingByLocation < Metric
      include Subject

      def calculate
        RawStripeTransaction.select(
          "CASE
            WHEN COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'state', '') <> '' THEN
              TRIM(UPPER(
                  CONCAT_WS(' - ',
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'country', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'state', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'postal_code', '')
                  )
              ))
            ELSE
              TRIM(UPPER(
                  CONCAT_WS(' - ',
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'country', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'postal_code', '')
                  )
              ))
          END AS location",
          "SUM(raw_stripe_transactions.amount_cents) * -1 AS amount_spent"
        )
                            .joins("LEFT JOIN canonical_transactions ct ON raw_stripe_transactions.id = ct.transaction_source_id")
                            .joins("LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id")
                            .where("EXTRACT(YEAR FROM date_posted) = ?", 2024)
                            .where("event_mapping.event_id = ?", event.id)
                            .group(
                              "CASE
            WHEN COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'state', '') <> '' THEN
              TRIM(UPPER(
                  CONCAT_WS(' - ',
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'country', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'state', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'postal_code', '')
                  )
              ))
            ELSE
              TRIM(UPPER(
                  CONCAT_WS(' - ',
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'country', ''),
                      COALESCE(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'postal_code', '')
                  )
              ))
          END"
                            )
                            .order(Arel.sql("SUM(raw_stripe_transactions.amount_cents) * -1 DESC"))
                            .each_with_object({}) { |item, hash| hash[self.geocode(item[:location])] = item[:amount_spent] }

      end

    end
  end

end
