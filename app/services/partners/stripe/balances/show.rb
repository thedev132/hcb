# frozen_string_literal: true

module Partners
  module Stripe
    module Balances
      class Show
        include StripeService

        def initialize(id:)
          @id = id
        end

        def run
          ::StripeService::Balance.retrieve(attrs)
        end

        private

        def attrs
          {
            id: @id
          }
        end
      end
    end
  end
end
