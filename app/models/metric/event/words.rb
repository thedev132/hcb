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
    class Words < Metric
      include Subject

      def calculate
        transactions =
          CanonicalTransaction
          .joins("LEFT JOIN canonical_event_mappings ON canonical_transactions.id = canonical_event_mappings.canonical_transaction_id")
          .where("canonical_event_mappings.event_id = ? AND EXTRACT(YEAR FROM canonical_transactions.created_at) = ?", event.id, 2023)

        common = ["the", "of", "and", "to", "in", "is", "for", "from", "a"]

        word_frequency = Hash.new(0)

        transactions.each do |transaction|
          memo = transaction.memo.to_s.downcase
          words = memo.scan(/\b\w+\b/)
          words.each do |word|
            word = word.downcase
            next if common.include?(word) || is_numeric?(word)

            word_frequency[word] += 1
          end
        end

        word_frequency

      end

      private

      def is_numeric?(str)
        !Float(str).nil? rescue false
      end

    end
  end

end
