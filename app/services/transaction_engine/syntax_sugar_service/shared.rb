module TransactionEngine
  module SyntaxSugarService
    module Shared
      OUTGOING_CHECK_MEMO_PART = "CHECK TO ACCOUNT REDACTED"
      OUTGOING_ACH_MEMO_PART = "BUSBILLPAY" # possibly not guaranteed from SVB bank

      private

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def memo
        @memo ||= @canonical_transaction.memo.to_s
      end

      def memo_upcase
        @memo_upcase ||= memo.upcase
      end
      
      def outgoing_check?
        memo_upcase.include?(OUTGOING_CHECK_MEMO_PART)
      end

      def likely_outgoing_check_number
        memo_upcase.gsub(OUTGOING_CHECK_MEMO_PART, "").strip
      end

      def outgoing_ach?
        memo_upcase.include?(OUTGOING_ACH_MEMO_PART)
      end
      
      def likely_outgoing_ach_name
        memo_upcase.split(OUTGOING_ACH_MEMO_PART)[0].strip
      end
    end
  end
end

