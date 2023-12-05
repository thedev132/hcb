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
  module User
    class LostReceiptCount < Metric
      include Subject

      def calculate
        count = 0

        stripe_cards = user.stripe_cards.includes(:event)
        emburse_cards = user.emburse_cards.includes(:event)

        (stripe_cards + emburse_cards).each do |card|
          card.hcb_codes.missing_receipt.each do |hcb_code|
            next unless hcb_code.receipt_required?

            count += 1
          end
        end

        count
      end

    end
  end

end
