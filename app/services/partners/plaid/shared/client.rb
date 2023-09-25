# frozen_string_literal: true

module Partners
  module Plaid
    module Shared
      module Client
        private

        def plaid_client
          configuration = ::Plaid::Configuration.new
          configuration.server_index = ::Plaid::Configuration::Environment[plaid_env]
          configuration.api_key["PLAID-CLIENT-ID"] = plaid_client_id
          configuration.api_key["PLAID-SECRET"] = plaid_secret

          api_client = ::Plaid::ApiClient.new(configuration)

          ::Plaid::PlaidApi.new(api_client)
        end

        def plaid_client_id
          Rails.application.credentials.plaid[:client_id]
        end

        def plaid_secret
          case plaid_env
          when "development"
            Rails.application.credentials.plaid[:development_secret]
          when "sandbox"
            Rails.application.credentials.plaid[:sandbox_secret]
          end
        end

        def plaid_public_key
          Rails.application.credentials.plaid[:public_key]
        end

        def plaid_env
          # Since we're only using one account & Plaid's development plan supports up
          # to 100 accounts, we're just going to stick with the development key in
          # production for now. Plaid is essentially read-only, so this also works in development.
          "development"
        end
      end
    end
  end
end
