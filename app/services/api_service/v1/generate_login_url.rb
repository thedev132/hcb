# frozen_string_literal: true

module ApiService
  module V1
    class GenerateLoginUrl
      def initialize(partner_id:, organization_identifier:)
        @partner_id = partner_id
        @organization_identifier = organization_identifier
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
        @organization ||= partner.events.find_by!(organization_identifier: clean_organization_identifier)
      end

      def clean_organization_identifier
        @organization_identifier.to_s.strip
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end
    end
  end
end
