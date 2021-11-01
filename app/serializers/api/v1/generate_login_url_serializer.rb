# frozen_string_literal: true

module Api
  module V1
    class GenerateLoginUrlSerializer
      def initialize(login_url:, organization_public_id:)
        @login_url = login_url
        @organization_public_id = organization_public_id
      end

      def run
        {
          data: data
        }
      end

      private

      def data # this method is also used by Api::V1::OrganizationSerializer
        {
          organization_id: @organization_public_id,
          loginUrl: @login_url
        }
      end
    end
  end
end
