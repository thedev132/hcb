# frozen_string_literal: true

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
        @canonical_transactions ||= CanonicalTransaction.includes(:receipts).where(id: canonical_event_mappings.pluck(:canonical_transaction_id)).order("date desc, id desc")
      end

      def canonical_transaction_ids
        @canonical_transaction_ids ||= canonical_event_mappings.pluck(:canonical_transaction_id)
      end
    end
  end
end
