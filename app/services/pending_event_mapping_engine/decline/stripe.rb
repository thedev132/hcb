module PendingEventMappingEngine
  module Decline
    class Stripe
      def run
        unsettled.find_each do |cpt|
          st = cpt.raw_pending_stripe_transaction.stripe_transaction

          status = st["status"]
          approved = st["approved"]

          # 1. identify declined (closed & not approved) transactions
          if status == "closed" && approved == false
            # 2. mark this as decliend
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.stripe.where('date <= ?', 2.weeks.ago)
      end
    end
  end
end
