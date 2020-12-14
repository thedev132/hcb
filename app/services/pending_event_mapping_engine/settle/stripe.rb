module PendingEventMappingEngine
  module Settle
    class Stripe
      def run
        unsettled.find_each do |cpt|
          stripe_authorization_id = cpt.raw_pending_stripe_transaction.stripe_transaction_id

          raw_stripe_transactions = RawStripeTransaction.where(stripe_authorization_id: stripe_authorization_id)

          raw_stripe_transactions.each do |rst|
            # 1. lookup canonical
            rst.hashed_transactions.each do |ht|
              ct = ht.canonical_transaction

              next unless ct

              # 2. mark no longer pending
              attrs = {
                canonical_transaction_id: ct.id,
                canonical_pending_transaction_id: cpt.id
              }
              CanonicalPendingSettledMapping.create!(attrs)
            end
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.stripe
      end
    end
  end
end
