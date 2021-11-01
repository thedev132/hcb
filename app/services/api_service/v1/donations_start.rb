# frozen_string_literal: true

module ApiService
  module V1
    class DonationsStart
      def initialize(partner_id:, organization_public_id:)
        @partner_id = partner_id
        @organization_public_id = organization_public_id
      end

      def run
        event.partner_donations.create!
      end

      private

      def partner
        @partner ||= Partner.find(@partner_id)
      end

      def event
        partner.events.find_by_public_id(organization_public_id)
      end

      def clean_organization_public_id
        @organization_public_id.to_s.strip
      end
    end
  end
end
