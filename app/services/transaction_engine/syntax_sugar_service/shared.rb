module TransactionEngine
  module SyntaxSugarService
    module Shared
      OUTGOING_CHECK_MEMO_PART = "CHECK TO ACCOUNT REDACTED"
      OUTGOING_ACH_MEMO_PART = "BUSBILLPAY" # possibly not guaranteed from SVB bank
      INCOMING_INVOICE_MEMO_PART1 = "HACKC PAYOUT"
      INCOMING_INVOICE_MEMO_PART2 = "HACK CLUB BANK PAYOUT"
      FEE_REFUND_MEMO_PART1 = "FEE REFUND"
      FEE_REFUND_MEMO_PART2 = "FROM ACCOUNT"

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

      def incoming_invoice?
        memo_upcase.include?(INCOMING_INVOICE_MEMO_PART1) || memo_upcase.include?(INCOMING_INVOICE_MEMO_PART2)
      end

      def likely_incoming_invoice_short_name
        memo_upcase.gsub(INCOMING_INVOICE_MEMO_PART1, "").gsub(INCOMING_INVOICE_MEMO_PART2, "").split(" ")[0]
      end

      def likely_invoice_for_fee_refund_hex_random_id
        memo_upcase.gsub(FEE_REFUND_MEMO_PART1, "").gsub(FEE_REFUND_MEMO_PART2, "").split(" ")[0]
      end

      def fee_refund?
        memo_upcase.include?(FEE_REFUND_MEMO_PART1) && memo_upcase.include?(FEE_REFUND_MEMO_PART2)
      end

    end
  end
end

