module TransactionEngine
  module FriendlyMemoService
    class AssignAllForEvent
      BATCH_SIZE = 100

      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        event.canonical_transactions.find_each(batch_size: BATCH_SIZE).each do |ct|
          friendly_memo = generate_friendly_memo(ct)

          ::CanonicalTransactionService::SetFriendlyMemo.new(canonical_transaction: ct, friendly_memo: friendly_memo).run
        end
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def generate_friendly_memo(canonical_transaction)
        ::TransactionEngine::FriendlyMemoService::Generate.new(canonical_transaction: canonical_transaction).run
      end
    end
  end
end
