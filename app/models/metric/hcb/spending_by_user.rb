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
  module Hcb
    class SpendingByUser < Metric
      include AppWide

      def calculate
        ActiveRecord::Base.connection.exec_query('

				SELECT
				users.full_name,
				(SELECT SUM(dollars_spent) AS spent
				FROM (
						SELECT SUM(amount_cents) * -1 AS dollars_spent
						FROM "raw_stripe_transactions"
						WHERE raw_stripe_transactions.stripe_transaction->>\'cardholder\' IN (
								SELECT stripe_id FROM "stripe_cardholders" WHERE user_id = users.id
						) AND EXTRACT(YEAR FROM date_posted) = 2023

						UNION ALL

						SELECT SUM(amount) AS dollars_spent
						FROM "ach_transfers"
						WHERE EXTRACT(YEAR FROM created_at) = 2023
						AND creator_id = users.id

						UNION ALL

						SELECT SUM(amount) AS dollars_spent
						FROM "disbursements"
						WHERE EXTRACT(YEAR FROM created_at) = 2023
						AND requested_by_id = users.id

						UNION ALL

						SELECT SUM(amount) AS dollars_spent
						FROM (
								SELECT amount
								FROM "increase_checks"
								WHERE EXTRACT(YEAR FROM created_at) = 2023
								AND user_id IN (users.id)
								UNION ALL
								SELECT amount
								FROM "checks"
								WHERE EXTRACT(YEAR FROM created_at) = 2023
								AND creator_id IN (users.id)
						) AS combined_table
				) AS combined_result)
				FROM "users"
				WHERE users.full_name IS NOT NULL
				ORDER BY spent desc
				LIMIT 10000
				').reject { |hash| hash["spent"].nil? }
                          .map { |item| [item["full_name"], item["spent"].to_f] }
                          .sort_by { |_, spent| -spent }
                          .to_h
      end

    end
  end

end
