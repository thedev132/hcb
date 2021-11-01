# frozen_string_literal: true

module ApiService
  module V1
    class Organization
      def initialize(partner_id:, organization_public_id:)
        @partner_id = partner_id
        @organization_public_id = organization_public_id
      end

      def run
        partner.events.find_by_public_id(clean_organization_identifier)
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

      def clean_organization_identifier
        @organization_public_id.to_s.strip
      end

    end
  end
end
