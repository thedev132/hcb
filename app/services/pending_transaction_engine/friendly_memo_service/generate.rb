module PendingTransactionEngine
  module FriendlyMemoService
    class Generate
      def initialize(pending_canonical_transaction:)
        @pending_canonical_transaction = pending_canonical_transaction
      end

      def run
        return "CHECK ##{check_number}" if outgoing_check?

        memo
      end

      private

      def memo
        @memo ||= @pending_canonical_transaction.memo
      end

      def memo_upcase
        memo.upcase
      end

      def outgoing_check?
        @outgoing_check ||= raw_pending_outgoing_check_transaction.present?
      end

      def raw_pending_outgoing_check_transaction
        @raw_pending_outgoing_check_transaction ||= @pending_canonical_transaction.raw_pending_outgoing_check_transaction
      end

      def check_number
        raw_pending_outgoing_check_transaction.check_number
      end
    end
  end
end

