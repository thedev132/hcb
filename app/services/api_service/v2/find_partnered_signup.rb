# frozen_string_literal: true

module ApiService
  module V2
    class FindPartneredSignup
      def initialize(partner_id:, partnered_signup_public_id:)
        @partner_id = partner_id
        @partnered_signup_public_id = partnered_signup_public_id
      end

      def run
        PartneredSignup.find_by_public_id(partnered_signup_public_id)
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

      def partnered_signup_public_id
        @partnered_signup_public_id.to_s.strip
      end

    end
  end
end
