module PendingEventMappingEngine
  module Settle
    class Stripe
      def run
        unsettled.find_each do |cpt|
          #pp cpt.raw_pending_stripe_transaction.stripe_transaction_id

          # TODO
          # 1. use the above iauth stripe transaction id to identify a canonical transaction from stripe
          # 2. lookup the raw_stripe_transaction with that iauth identifier
          # 3. use it to then lookup the canonical transaction and map it
          # 4. write to CanonicalPendingSettledMapping

          #attrs = {
          #  canonical_transaction_id: #cpt.raw_pending_stripe_transaction.likely_event_id,
          #  canonical_pending_transaction_id: cpt.id
          #}
          #CanonicalPendingSettledMapping.create!(attrs)
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.stripe
      end
    end
  end
end
