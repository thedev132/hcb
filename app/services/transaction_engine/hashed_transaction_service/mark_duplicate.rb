# frozen_string_literal: true

module TransactionEngine
  module HashedTransactionService
    class MarkDuplicate
      def initialize(valid_hashed_transaction_id:, duplicate_hashed_transaction_id:)
        @valid_tx = HashedTransaction.find valid_hashed_transaction_id
        @duplicate_tx = HashedTransaction.find duplicate_hashed_transaction_id
      end

      def run
        raise ArgumentError unless @valid_tx.canonical_transaction.present?
        raise ArgumentError if @duplicate_tx.canonical_transaction.present?

        @duplicate_tx.duplicate_of_hashed_transaction = @valid_tx
        @duplicate_tx.save!
      end
    end
  end
end
