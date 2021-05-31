module EventMappingEngine
  module GuessEventId
    class BankFee
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        bank_fee.try(:event).try(:id)
      end

      private

      def bank_fee
        @bank_fee ||= ::BankFee.in_transit.where(event_id: parsed_event_id, amount_cents: amount_cents).order("created_at asc").first
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end

      def parsed_event_id
        @canonical_transaction.memo.upcase.gsub("HACK CLUB BANK FEE TO ACCOUNT REDACTED", "").strip
      end
    end
  end
end
