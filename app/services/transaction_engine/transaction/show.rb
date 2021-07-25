# frozen_string_literal: true

module TransactionEngine
  module Transaction
    class Show
      def initialize(canonical_transaction_id:)
        @canonical_transaction_id = canonical_transaction_id
      end

      def run
        ::CanonicalTransaction.find(@canonical_transaction_id)
      end
    end
  end
end
