module EventMappingEngine
  module GuessEventId
    class FeeReimbursement
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return unless fee_reimbursement.try(:event)

        fee_reimbursement.event.id
      end

      private

      def fee_reimbursement
        @fee_reimbursement ||= ::FeeReimbursement.where("transaction_memo ilike '%#{unique_identifier}%'").first
      end

      def memo
        @memo ||= @canonical_transaction.memo
      end

      def unique_identifier
        @unique_identifier ||= memo.upcase.gsub("FEE REFUND", "")
          .gsub("FROM ACCOUNT REDACTED", "").strip
      end
    end
  end
end
