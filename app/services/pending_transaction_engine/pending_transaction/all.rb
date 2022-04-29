# frozen_string_literal: true

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
        @canonical_pending_transactions ||=
          begin
            cpts = CanonicalPendingTransaction.includes(:raw_pending_stripe_transaction)
                                              .unsettled
                                              .where(id: canonical_pending_event_mappings.pluck(:canonical_pending_transaction_id))
                                              .order("date desc, canonical_pending_transactions.id desc")

            cpts = cpts.search_memo(@search) if @search.present?
            cpts
          end
      end

    end
  end
end
