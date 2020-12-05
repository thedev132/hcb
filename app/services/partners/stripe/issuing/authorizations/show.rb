module Partners
  module Stripe
    module Issuing
      module Authorizations
        class Show
          include StripeService

          def initialize(id:)
            @id = id
          end

          def run
            ::StripeService::Issuing::Authorization.retrieve(@id)
          end
        end
      end
    end
  end
end
