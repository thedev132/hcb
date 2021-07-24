# frozen_string_literal: true

module Partners
  module Stripe
    module Topup
      class Create
        include ::Partners::Stripe::Shared::Opts

        def initialize(stripe_api_key:, amount_cents:, statement_descriptor:)
          @stripe_api_key = stripe_api_key
          @amount_cents = amount_cents
          @statement_descriptor = statement_descriptor
        end

        def run
          ::Stripe::Topup.create(attrs, opts)
        end

        private

        def attrs
          {
            amount: @amount_cents,
            currency: "usd",
            statement_descriptor: @statement_descriptor,
            destination_balance: nil # normal balance (rather than issuing) https://stripe.com/docs/api/topups/create#create_topup-destination_balance
          }
        end
      end
    end
  end
end
