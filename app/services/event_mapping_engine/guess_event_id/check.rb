module EventMappingEngine
  module GuessEventId
    class Check
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        check.event.id
      end

      private

      def check
        @check ||= ::Check.in_transit_and_processed.where(check_number: check_number, amount: -amount_cents).order("created_at asc").first
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def memo
        @canonical_transaction.memo
      end

      def check_number
        @check_number ||= memo.upcase.gsub("CHECK TO ACCOUNT REDACTED", "").strip
      end
    end
  end
end
