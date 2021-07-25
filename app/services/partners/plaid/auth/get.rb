# frozen_string_literal: true

module Partners
  module Plaid
    module Auth
      class Get
        include ::Partners::Plaid::Shared::Client

        def initialize(access_token:)
          @access_token = access_token
        end

        def run
          plaid_client.auth.get(@access_token)
        end
      end
    end
  end
end
