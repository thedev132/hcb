# frozen_string_literal: true

module Partners
  module Stripe
    module Issuing
      module Authorizations
        class List
          include StripeService

          def run(&block)
            stripe_authorizations(&block)
          end

          private

          def stripe_authorizations(&block)
            resp = fetch_authorizations

            ts = resp.data
            if block_given?
              ts.each { |t| block.call(t) }
            end

            while resp.has_more
              starting_after = ts.last.id

              resp = fetch_authorizations(starting_after:)

              if block_given?
                resp.data.each { |t| block.call(t) }
              else
                ts += resp.data
              end
            end

            ts unless block_given?
          end

          def fetch_authorizations(starting_after: nil)
            ::StripeService::Issuing::Authorization.list(list_attrs(starting_after:))
          end

          def list_attrs(starting_after:)
            {
              starting_after:,
              limit: 100
            }
          end

        end
      end
    end
  end
end
