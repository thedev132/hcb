# frozen_string_literal: true

module Api
  module V1
    class PartneredSignupSerializer
      def initialize(partnered_signup:)
        @partnered_signup = partnered_signup
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        {
          id: @partnered_signup.public_id,
          status: @partnered_signup.status,
          redirect_url: @partnered_signup.redirect_url,
          connect_url: @partnered_signup.continue_url,
          owner_phone: @partnered_signup.owner_phone,
          owner_email: @partnered_signup.owner_email,
          owner_name: @partnered_signup.owner_name,
          owner_address: @partnered_signup.owner_address,
          owner_birthdate: @partnered_signup.owner_birthdate,
          country: @partnered_signup.country,
          organization_name: @partnered_signup.organization_name,
          organization_id: @partnered_signup.event&.public_id, # nil if event does not exist yet
        }
      end
    end
  end
end
