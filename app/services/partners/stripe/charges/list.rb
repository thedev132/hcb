module Partners
  module Stripe
    module Charges
      class List
        include StripeService

        def initialize(start_date: nil)
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          resp = fetch_charges

          ts = resp.data

          ts.each do |t|
            if t.metadata["donationIdentifier"].present?
              yield t
            end
          end

          while resp.has_more
            starting_after = ts.last.id

            resp = fetch_charges(starting_after: starting_after)

            ts = resp.data

            ts.each do |t|
              if t.metadata["donationIdentifier"].present?
                yield t
              end
            end
          end

          ts.each do |t|
            if t.metadata["donationIdentifier"].present?
              yield t
            end
          end

          nil
        end

        private

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
