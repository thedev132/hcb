module Partners
  module Stripe
    module Refunds
      class Create
        include StripeService

        def initialize(payment_intent_id:)
          @payment_intent_id = payment_intent_id
        end

        def run
          ::StripeService::Refund.create(attrs)
        end

        private

        def attrs
          {
            payment_intent: @payment_intent_id,
          }
        end
      end
    end
  end
end
