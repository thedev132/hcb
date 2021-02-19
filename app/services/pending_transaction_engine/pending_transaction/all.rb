module PendingTransactionEngine
  module PendingTransaction
    class All
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        canonical_pending_transactions
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_pending_event_mappings
        @canonical_pending_event_mappings ||= CanonicalPendingEventMapping.where(event_id: event.id)
      end

      def canonical_pending_transactions
        @canonical_pending_transactions ||= CanonicalPendingTransaction.unsettled.where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id)).order("date desc")
      end
    end
  end
end
