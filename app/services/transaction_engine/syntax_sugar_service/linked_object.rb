module TransactionEngine
  module SyntaxSugarService
    class LinkedObject
      OUTGOING_CHECK_MEMO_PART = "CHECK TO ACCOUNT REDACTED"

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        if memo.present?

          return likely_check if outgoing_check?

          nil
        end
      end

      private

      def memo
        @memo ||= @canonical_transaction.memo.to_s
      end

      def memo_upcase
        @memo_upcase ||= memo.upcase
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def outgoing_check?
        memo_upcase.include?(OUTGOING_CHECK_MEMO_PART)
      end

      def likely_outgoing_check_number
        memo_upcase.gsub(OUTGOING_CHECK_MEMO_PART, "").strip
      end

      def likely_check
        event.checks.where(check_number: likely_outgoing_check_number).first
      end

      def event
        @event ||= @canonical_transaction.event
      end
    end
  end
end
