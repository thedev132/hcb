# frozen_string_literal: true

module Partners
  module Stripe
    module Charges
      class List
        include ::Partners::Stripe::Shared::Opts

        def initialize(stripe_api_key:, start_date: nil)
          @stripe_api_key = stripe_api_key
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          starting_after = nil

          loop do
            resp = fetch_charges(starting_after: starting_after)

            ts = resp.data
            break if ts.empty?

            ts.each do |t|
              if t.metadata["hcb_metadata_identifier"].present?
                yield t
              else
                Airbrake.notify("Stripe charge #{t.id} has no metadata identifier")
              end
            end

            starting_after = ts.last.id
          end
        end

        private

        def fetch_charges(starting_after: nil)
          ::Stripe::Charge.list(list_attrs(starting_after: starting_after), opts)
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
