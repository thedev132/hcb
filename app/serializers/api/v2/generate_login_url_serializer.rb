# frozen_string_literal: true

module Api
  module V2
    class GenerateLoginUrlSerializer
      # @param [LoginToken] login_token
      def initialize(organization_public_id:, login_token:)
        @organization_public_id = organization_public_id.strip
        @login_token = login_token
      end

      def run
        {
          data:
        }
      end

      private

      def data
        {
          organization_id: @organization_public_id,
          login_url: @login_token.login_url
        }
      end

    end
  end
end
