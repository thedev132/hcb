# frozen_string_literal: true

module Api
  module V2
    class GenerateLoginUrlSerializer
      def initialize(email:, organization_public_id:)
        @email = email
        @organization_public_id = organization_public_id
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        {
          # organization_id: @organization_public_id,
          login_url: Rails.application.routes.url_helpers.auth_users_url(email: @email)
        }
      end
    end
  end
end
