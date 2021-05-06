module EventMappingEngine
  module GuessEventId
    class Ach
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        ach.try(:event).try(:id)
      end

      private

      def ach
        @ach ||= ::AchTransfer.in_transit.where(amount: -amount_cents).order("created_at asc").first
      end

      def amount_cents
        @canonical_transaction.amount_cents
      end
    end
  end
end
