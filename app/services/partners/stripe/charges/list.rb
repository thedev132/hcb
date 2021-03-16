module Partners
  module Stripe
    module Charges
      class List
        include StripeService

        def initialize(start_date: nil)
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          stripe_charges
        end

        private

        def stripe_charges
          resp = fetch_charges

          ts = resp.data

          while resp.has_more
            starting_after = ts.last.id

            resp = fetch_charges(starting_after: starting_after)

            ts += resp.data
          end

          ts
        end

        def fetch_charges(starting_after: nil)
          ::StripeService::Charge.list(list_attrs(starting_after: starting_after))
        end

        def list_attrs(starting_after:)
          {
            created: { gte: @start_date.to_i },
            starting_after: starting_after,
            limit: 100
          }
        end
      end
    end
  end
end
