module PendingEventMappingEngine
  module Decline
    class Stripe
      def run
        unsettled.find_each do |cpt|
          st = cpt.raw_pending_stripe_transaction.stripe_transaction

          status = st["status"]
          approved = st["approved"]

          # 1. identify closed pending transactions (rejected)
          if status == "closed" && approved == false
            # 2. mark this as no longer pending. shouldn't display. it was rejected.
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
