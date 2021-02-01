module TransactionEngine
  module SyntaxSugarService
    class Memo
      OUTGOING_CHECK_MEMO_PART = "CHECK TO ACCOUNT REDACTED"

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        if memo.present?

          return "CHECK ##{likely_outgoing_check_number}" if outgoing_check?

          return "HACK CLUB BANK FEE" if hack_club_fee?

          return "FEE REFUND" if fee_refund?

          return "TRANSFER FROM ACCOUNT TO CARD BALANCE" if emburse_transfer_from_account_to_card_balance?

          return "TRANSFER FROM BANK ACCOUNT" if emburse_transfer_from_fiscal_sponsorship?

          return "DONATION" if donation?

          return "INVOICE" if invoice?

          return "DISBURSEMENT" if disbursement?

          memo

        else

          return "TRANSFER FROM BANK ACCOUNT" if amount_cents > 0 # emburse transaction

          return "TRANSFER BACK TO BANK ACCOUNT" if amount_cents < 0 # emburse transaction

          "" # IMPLEMENT

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

      def hack_club_fee?
        @canonical_transaction.fees.hack_club_fee.exists?
      end

      def outgoing_check?
        memo_upcase.include?(OUTGOING_CHECK_MEMO_PART)
      end

      def likely_outgoing_check_number
        memo_upcase.gsub(OUTGOING_CHECK_MEMO_PART, "").strip
      end

      def fee_refund?
        memo_upcase.include?("FEE REFUND") && memo_upcase.include?("FROM ACCOUNT")
      end

      def emburse_transfer_from_account_to_card_balance?
        memo_upcase.include?("EMBURSE.COM EMBURSE.CO") || memo_upcase.include?("EMBURSE.COM TRANSFER")
      end

      def emburse_transfer_from_fiscal_sponsorship?
        memo_upcase.include?("TRANSFER FROM FISCAL SPONSORSHIP (NEW) - 7027") || memo_upcase.include?("TRANSFER FROM FS MAIN - 7027")
      end

      def donation?
        memo_upcase.include?("HACKC DONATE") || memo_upcase.include?("HACK CLUB BANK DONATE")
      end

      def invoice?
        memo_upcase.include?("HACKC PAYOUT") || memo_upcase.include?("HACK CLUB BANK PAYOUT")
      end

      def disbursement?
        memo_upcase.include?("HCB DISBURSE")
      end
    end
  end
end
