# frozen_string_literal: true

module Api
  module V2
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

      def data # this method is also used by Api::V2::OrganizationSerializer
        {
          organization_id: @organization_public_id,
          login_url: @login_url
        }
      end
    end
  end
end
