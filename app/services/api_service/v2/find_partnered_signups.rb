# frozen_string_literal: true

module ApiService
  module V2
    class FindPartneredSignups
      def initialize(partner_id:)
        @partner_id = partner_id
      end

      def run
        partner.partnered_signups
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

    end
  end
end
