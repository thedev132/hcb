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
        transactions = TransactionGroupingEngine::Transaction::All.new(event_id: event.id).run
        TransactionGroupingEngine::Transaction::AssociationPreloader.new(transactions:, event:).run!

        # 1. Filter transactions by year
        transactions.filter! { |t| t.date&.to_date&.year == 2024 }

        # 2. Get words from transaction memos
        words = transactions.flat_map { |t| t.local_hcb_code.memo(event:).split }

        # 3. Clean words
        words.map!(&method(:clean))

        # 4. Remove stop words, numbers, and stuff we don't want
        words.reject! { |w| stop_word?(w) || numeric?(w) || !meaningful?(w) }

        # 5. Count them all up
        frequency = words.tally

        # 6. Sort by frequency
        sort frequency
      end

      def metric
        # JSONB will disregard key order when saving, so we need to sort again
        sort super
      end

      private

      def clean(word)
        word.downcase.match(/\A[("]*(.*?)[):,"]*\Z/)[1]
      end

      def stop_word?(str)
        str.in? %w[the of and to in is for from a]
      end

      def numeric?(str)
        !Float(str).nil? rescue false
      end

      def meaningful?(str)
        # we don't want stuff too short, but we also want emojis
        str.size >= 3 || str.match?(/\A\p{Emoji}\z/)
      end

      def sort(hash)
        hash.sort_by { |_, value| value }.reverse!.to_h
      end

    end
  end

end
