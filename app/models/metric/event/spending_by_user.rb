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
    class SpendingByUser < Metric
      include Subject

      def calculate
        sql = ActiveRecord::Base.sanitize_sql([<<~SQL, { event_id: event.id }])
          SELECT user_id, sum(dollars_spent) as spent
          FROM (
              SELECT raw_stripe_transactions.amount_cents * -1 AS dollars_spent, stripe_cardholders.user_id
              FROM "raw_stripe_transactions"
              LEFT JOIN canonical_transactions ct ON raw_stripe_transactions.id = ct.transaction_source_id AND ct.transaction_source_type = 'RawStripeTransaction'
              LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
              LEFT JOIN "stripe_cardholders" on stripe_cardholders.stripe_id = raw_stripe_transactions.stripe_transaction->>'cardholder'
              WHERE EXTRACT(YEAR FROM raw_stripe_transactions.date_posted) = 2024
              AND event_mapping.event_id = :event_id

              UNION ALL

              SELECT ach_transfers.amount AS dollars_spent, ach_transfers.creator_id as user_id
              FROM "ach_transfers"
              LEFT JOIN canonical_transactions ct ON ach_transfers.id = ct.transaction_source_id
              LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
              WHERE EXTRACT(YEAR FROM ach_transfers.created_at) = 2024
              AND event_mapping.event_id = :event_id

              UNION ALL

              SELECT disbursements.amount AS dollars_spent, disbursements.requested_by_id as user_id
              FROM "disbursements"
              LEFT JOIN canonical_transactions ct ON disbursements.id = ct.transaction_source_id
              LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
              WHERE EXTRACT(YEAR FROM disbursements.created_at) = 2024
              AND event_mapping.event_id = :event_id

              UNION ALL

              SELECT increase_checks.amount as dollars_spent, increase_checks.user_id
              FROM "increase_checks"
              LEFT JOIN canonical_transactions ct ON increase_checks.id = ct.transaction_source_id
              LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
              WHERE EXTRACT(YEAR FROM increase_checks.created_at) = 2024
              AND event_mapping.event_id = :event_id

              UNION ALL

              SELECT checks.amount, creator_id as user_id
              FROM "checks"
              LEFT JOIN canonical_transactions ct ON checks.id = ct.transaction_source_id
              LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
              WHERE EXTRACT(YEAR FROM checks.created_at) = 2024
              AND event_mapping.event_id = :event_id

          ) results
          group by user_id
          ORDER BY spent desc
        SQL

        raw = ActiveRecord::Base.connection.exec_query(sql)

        raw.map { |item| [item["user_id"], item["spent"].to_f] }
           .sort_by { |_, spent| -spent }
           .to_h
      end

    end
  end

end
