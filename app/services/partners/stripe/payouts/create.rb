module Partners
  module Stripe
    module Payouts
      class Create
        include StripeService

        def initialize(amount_cents:, statement_descriptor:, donation_identifier:)
          @amount_cents = amount_cents
          @statement_descriptor = statement_descriptor
          @donation_identifier = donation_identifier
        end

        def run
          ::StripeService::Payout.create(attrs)
        end

        private

        def attrs
          {
            amount: @amount_cents,
            currency: "usd",
            description: @statement_descriptor,
            statement_descriptor: @statement_descriptor,
            metadata: metadata
          }
        end

        def metadata
          {
            donationIdentifier: donation_identifier
          }
        end
      end
    end
  end
end
