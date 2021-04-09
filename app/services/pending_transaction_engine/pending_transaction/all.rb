module PendingTransactionEngine
  module PendingTransaction
    class All
      def initialize(event_id:, search: nil)
        @event_id = event_id
        @search = search
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
        @canonical_pending_transactions ||= begin
          if @search.present?
            CanonicalPendingTransaction.unsettled.where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id)).search_memo(@search).order("date desc, canonical_pending_transactions.id desc")
          else
            CanonicalPendingTransaction.unsettled.where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id)).order("date desc, canonical_pending_transactions.id desc")
          end
        end
      end
    end
  end
end
