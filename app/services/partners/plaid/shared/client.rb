# frozen_string_literal: true

module Partners
  module Plaid
    module Shared
      module Client
        private

        def plaid_client
          ::Plaid::Client.new(env: plaid_env,
                              client_id: plaid_client_id,
                              secret: plaid_secret,
                              public_key: plaid_public_key)
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
