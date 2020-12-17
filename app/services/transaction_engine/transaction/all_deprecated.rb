module TransactionEngine
  module Transaction
    class AllDeprecated
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        unified_transactions.sort_by(&:created_at).reverse
      end

      private

      def unified_transactions
        event.transactions.unified_list.includes(:fee_relationship, :comments) +
        event.stripe_authorizations.unified_list.includes(:receipts, stripe_card: :user) +
        event.emburse_transactions.unified_list.includes(:comments)
      end

      def event
        @event ||= Event.find(@event_id)
      end
    end
  end
end
