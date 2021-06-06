module Partners
  module Stripe
    module Charges
      class Show
        include ::Partners::Stripe::Shared::Opts

        def initialize(stripe_api_key:, id:)
          @stripe_api_key = stripe_api_key
          @id = id
        end

        def run
          ::Stripe::Charge.retrieve(attrs, opts)
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
