# frozen_string_literal: true

module Partners
  module Stripe
    module Issuing
      module Cards
        class Show
          include StripeService

          def initialize(id:, expand: [])
            @id = id
            @expand = expand
          end

          def run
            ::StripeService::Issuing::Card.retrieve(attrs)
          end

          private

          def attrs
            {
              id: @id,
              expand: @expand
            }
          end
        end
      end
    end
  end
end
