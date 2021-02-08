module PendingTransactionEngine
  module FriendlyMemoService
    class Generate
      def initialize(pending_canonical_transaction:)
        @pending_canonical_transaction = pending_canonical_transaction
      end

      def run
        memo
      end

      private

      def memo
        @memo ||= @pending_canonical_transaction.memo
      end
    end
  end
end

