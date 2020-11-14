module TransactionEngine
  module Transaction
    class All
      def initialize(event_id:)
        @event_id = event_id
      end

      def each(&block)
        each_transactions.each(&block)
      end

      def any?
        canonical_transactions.present?
      end

      def to_a
        each_transactions.to_a
      end

      def total_pages
        1
      end

      def current_page
        1
      end

      def limit_value
        1
      end

      private

      def each_transactions 
        @each_transactions ||= canonical_transactions.map { |ct| ::TransactionEngine::Transaction::Single.new(canonical_transaction: ct) }
      end

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_event_mappings
        @canonical_event_mappings ||= CanonicalEventMapping.where(event_id: event.id)
      end

      def canonical_transactions
        @canonical_transactions ||= CanonicalTransaction.where(id: canonical_event_mappings.pluck(:canonical_transaction_id))
      end
    end
  end
end
