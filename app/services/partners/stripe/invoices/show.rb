module Partners
  module Stripe
    module Invoices
      class Show
        include StripeService

        def initialize(id:)
          @id = id
        end

        def run
          ::StripeService::Invoice.retrieve(attrs)
        end

        private

        def attrs
          {
            id: @id,
            expand: ["charge.payment_method_details"]
          }
        end
      end
    end
  end
end
