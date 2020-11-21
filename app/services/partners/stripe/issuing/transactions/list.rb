module Partners
  module Stripe
    module Issuing
      module Transactions
        class List
          include StripeService

          def initialize
          end

          def run
            ::StripeService::Issuing::Transaction.list(list_attrs)
          end

          private

          def list_attrs
            {
              limit: 3
            }
          end
        end
      end
    end
  end
end
