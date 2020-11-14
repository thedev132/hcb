module TransactionEngine
  module Transaction
    class Single
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def amount
        @canonical_transaction.amount
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def date
        @canonical_transaction.date
      end

      def display_name
        @canonical_transaction.memo
      end

      def filter_data
        {} # TODO: implement
      end

      def comments
        [] # TODO: implement
      end


    end
  end
end
