module Partners
  module Stripe
    module Issuing
      module Transactions
        class List
          include StripeService

          def initialize(start_date: nil)
            @start_date = start_date || Time.now.utc - 1.month
          end

          def run
            stripe_transactions
          end

          private

          def stripe_transactions
            resp = fetch_transactions

            ts = resp.data

            while resp.has_more
              starting_after = ts.last.id

              resp = fetch_transactions(starting_after: starting_after)

              ts += resp.data
            end

            ts
          end

          def fetch_transactions(starting_after: nil)
            ::StripeService::Issuing::Transaction.list(list_attrs(starting_after: starting_after))
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
end
