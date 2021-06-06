module Partners
  module Stripe
    module Shared
      module Opts
        # https://github.com/stripe/stripe-ruby#per-request-configuration
        def opts
          raise ArgumentError, "@stripe_api_key must be set" unless @stripe_api_key.present?

          {
            stripe_version: "2018-02-28",
            api_key: @stripe_api_key
          }
        end
      end
    end
  end
end
