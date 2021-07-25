# frozen_string_literal: true

module Partners
  module Stripe
    module Payouts
      class List
        include StripeService

        def initialize(start_date: nil)
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          stripe_payouts
        end

        private

        def stripe_payouts
          resp = fetch_payouts

          ts = resp.data

          while resp.has_more
            starting_after = ts.last.id

            resp = fetch_payouts(starting_after: starting_after)

            ts += resp.data
          end

          ts
        end

        def fetch_payouts(starting_after: nil)
          ::StripeService::Payout.list(list_attrs(starting_after: starting_after))
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
