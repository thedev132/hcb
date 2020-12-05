module TransactionEngine
  module Transaction
    class All
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        canonical_transactions
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_event_mappings
        @canonical_event_mappings ||= CanonicalEventMapping.where(event_id: event.id)
      end

      def canonical_transactions
        @canonical_transactions ||= CanonicalTransaction.where(id: canonical_event_mappings.pluck(:canonical_transaction_id)).order('date desc')
      end
    end
  end
end
