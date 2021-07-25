# frozen_string_literal: true

module Partners
  module Stripe
    module Issuing
      module Authorizations
        class List
          include StripeService

          def run
            stripe_authorizations
          end

          private

          def stripe_authorizations
            resp = fetch_authorizations

            ts = resp.data

            while resp.has_more
              starting_after = ts.last.id

              resp = fetch_authorizations(starting_after: starting_after)

              ts += resp.data
            end

            ts
          end

          def fetch_authorizations(starting_after: nil)
            ::StripeService::Issuing::Authorization.list(list_attrs(starting_after: starting_after))
          end

          def list_attrs(starting_after:)
            {
              starting_after: starting_after,
              limit: 100
            }
          end
        end
      end
    end
  end
end
