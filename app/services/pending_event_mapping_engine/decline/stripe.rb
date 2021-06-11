module PendingEventMappingEngine
  module Decline
    class Stripe
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          rpst = cpt.raw_pending_stripe_transaction
          st = rpst.stripe_transaction

          status = st["status"]
          approved = st["approved"]

          # 1. identify declined (closed & not approved) transactions
          if status == "closed" && approved == false
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
          end

          # 2. identify authed (0 amount and a considerable amount of time has passed)
          if rpst.amount_cents == 0 && rpst.date_posted < Time.now.utc - 10.days
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
          end

          # 3. identify reversed (0 amount and a considerable amount of time has passed)
          if status == "reversed" && rpst.amount_cents < 0 && rpst.date_posted < Time.now.utc - 10.days
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
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
