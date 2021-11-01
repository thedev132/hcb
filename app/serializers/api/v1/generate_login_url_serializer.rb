# frozen_string_literal: true

module Api
  module V1
    class GenerateLoginUrlSerializer
      def initialize(login_url:, organization_identifier:)
        @login_url = login_url
        @organization_identifier = organization_identifier
      end

      def run
        {
          data: data
        }
      end

      private

      def data # this method is also used by Api::V1::OrganizationSerializer
        {
          organizationIdentifier: @organization_identifier,
          loginUrl: @login_url
        }
      end
    end
  end
end
