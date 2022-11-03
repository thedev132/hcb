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
        # Validate that the Partner has permission to create a login URL for
        # this user and organization
        unless organization.partner == @partner && user.events.include?(organization)
          raise ActiveRecord::RecordNotFound
        end

        ::UserService::GenerateToken.new(
          partner_id: @partner.id,
          user_id: user.id
        ).run
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
