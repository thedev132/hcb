# frozen_string_literal: true

module Partners
  module Stripe
    module Issuing
      module Transactions
        class Show
          include StripeService

          def initialize(id:)
            @id = id
          end

          def run
            ::StripeService::Issuing::Transaction.retrieve(@id)
          end
        end
      end
    end
  end
end
