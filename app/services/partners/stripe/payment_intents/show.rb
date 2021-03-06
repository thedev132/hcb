module Partners
  module Stripe
    module PaymentIntents
      class Show
        include StripeService

        def initialize(id:)
          @id = id
        end

        def run
          ::StripeService::PaymentIntent.retrieve(attrs)
        end

        private

        def attrs
          {
            id: @id,
            expand: ["charges.data.balance_transaction"]
          }
        end
      end
    end
  end
end
