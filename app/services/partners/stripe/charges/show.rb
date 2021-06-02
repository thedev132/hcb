module Partners
  module Stripe
    module Charges
      class Show
        include StripeService

        def initialize(id:)
          @id = id
        end

        def run
          ::StripeService::Charge.retrieve(attrs)
        end

        private

        def attrs
          {
            id: @id,
            expand: [
              "balance_transaction"
            ]
          }
        end
      end
    end
  end
end
