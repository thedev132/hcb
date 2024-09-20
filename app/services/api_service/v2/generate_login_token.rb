# frozen_string_literal: true

module ApiService
  module V2
    class GenerateLoginToken
      def initialize(partner:, user_email:, organization_public_id:)
        @partner = partner
        @user_email = user_email
        @organization_public_id = organization_public_id
      end

      def run
        Airbrake.notify("ApiService::V2::GenerateLoginToken")
      end

      private

      def user
        @user ||= User.find_by!(email: @user_email)
      end

      def organization
        @organization ||= Event.find_by_public_id!(clean_organization_public_id)
      end

      def clean_organization_public_id
        @organization_public_id.to_s.strip
      end

    end
  end
end
