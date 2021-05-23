# frozen_string_literal: true

module ApiService
  module V1
    class Organization
      def initialize(partner_id:, organization_identifier:)
        @partner_id = partner_id
        @organization_identifier = organization_identifier
      end

      def run
        partner.events.find_by(organization_identifier: clean_organization_identifier)
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

			def clean_organization_identifier
        @organization_identifier.to_s.strip
      end
			
    end
  end
end

