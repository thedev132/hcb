# frozen_string_literal: true

module ApiService
  module V1
    class GenerateLoginUrl
      def initialize(partner_id:, organization_public_id:)
        @partner_id = partner_id
        @organization_public_id = organization_public_id
      end

      def run
        token = ::UserService::GenerateToken.new(user_id: user.id).run

        Rails.application.routes.url_helpers.api_login_api_v1_index_url(loginToken: token)
      end

      private

      def user
        organization.users.first!
      end

      def organization
        @organization ||= partner.events.find_by_public_id(clean_organization_public_id)
      end

      def clean_organization_public_id
        @organization_public_id.to_s.strip
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end
    end
  end
end
