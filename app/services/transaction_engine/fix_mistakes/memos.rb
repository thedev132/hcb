module TransactionEngine
  module FixMistakes
    class Memos
      include ::TransactionEngine::Shared

      def initialize(start_date:)
        @start_date = start_date || last_1_month
      end

      def run
        ::CanonicalTransaction.where("date >= ?", @start_date).find_each(batch_size: 100) do |ct|
          if ct.memo != ct.hashed_transactions.first.memo
            ct.update_column(:memo, ct.hashed_transactions.first.memo)
          end
        end

        true
      end
    end
  end
end
