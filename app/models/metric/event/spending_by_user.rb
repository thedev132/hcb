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
        ActiveRecord::Base.connection.exec_query('

        SELECT
        users.id,
        (SELECT SUM(dollars_spent) AS spent
        FROM (
            SELECT SUM(raw_stripe_transactions.amount_cents) * -1 AS dollars_spent
            FROM "raw_stripe_transactions"
            LEFT JOIN canonical_transactions ct ON raw_stripe_transactions.id = ct.transaction_source_id
            LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
            WHERE raw_stripe_transactions.stripe_transaction->>\'cardholder\' IN (
                SELECT stripe_id FROM "stripe_cardholders" WHERE user_id = users.id
            ) AND EXTRACT(YEAR FROM raw_stripe_transactions.date_posted) = 2024
            AND event_mapping.event_id = %{event}

            UNION ALL

            SELECT SUM(ach_transfers.amount) AS dollars_spent
            FROM "ach_transfers"
            LEFT JOIN canonical_transactions ct ON ach_transfers.id = ct.transaction_source_id
            LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
            WHERE EXTRACT(YEAR FROM ach_transfers.created_at) = 2024
            AND creator_id = users.id
            AND event_mapping.event_id = %{event}

            UNION ALL

            SELECT SUM(disbursements.amount) AS dollars_spent
            FROM "disbursements"
            LEFT JOIN canonical_transactions ct ON disbursements.id = ct.transaction_source_id
            LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
            WHERE EXTRACT(YEAR FROM disbursements.created_at) = 2024
            AND requested_by_id = users.id
            AND event_mapping.event_id = %{event}

            UNION ALL

            SELECT SUM(amount) AS dollars_spent
            FROM (
                SELECT increase_checks.amount
                FROM "increase_checks"
                LEFT JOIN canonical_transactions ct ON increase_checks.id = ct.transaction_source_id
                LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
                WHERE EXTRACT(YEAR FROM increase_checks.created_at) = 2024
                AND increase_checks.user_id IN (users.id)
                AND event_mapping.event_id = %{event}
                UNION ALL
                SELECT checks.amount
                FROM "checks"
                LEFT JOIN canonical_transactions ct ON checks.id = ct.transaction_source_id
                LEFT JOIN canonical_event_mappings event_mapping ON ct.id = event_mapping.canonical_transaction_id
                WHERE EXTRACT(YEAR FROM checks.created_at) = 2024
                AND checks.creator_id IN (users.id)
                AND event_mapping.event_id = %{event}
            ) AS combined_table
        ) AS combined_result)
        FROM "users"
        WHERE users.full_name IS NOT NULL
        ORDER BY spent desc
        ' % { event: event.id }).reject { |hash| hash["spent"].nil? }
                          .map { |item| [item["id"], item["spent"].to_f] }
                          .sort_by { |_, spent| -spent }
                          .to_h
      end

    end
  end

end
