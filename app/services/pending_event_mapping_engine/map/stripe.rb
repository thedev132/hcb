module PendingEventMappingEngine
  module Map
    class Stripe
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          attrs = {
            event_id: cpt.raw_pending_stripe_transaction.likely_event_id,
            canonical_pending_transaction_id: cpt.id
          }
          CanonicalPendingEventMapping.create!(attrs)
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.stripe
      end
    end
  end
end
