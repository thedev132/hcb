# frozen_string_literal: true

module ApiService
  module V1
    class DonationStart
      def initialize(partner_id:,
                     organization_identifier:)
        @partner_id = partner_id
        @organization_identifier = organization_identifier
      end

      def run
        event.donations.create!(attrs)
      end

      private

      def attrs
        {
        }
      end

      def partner
        @partner ||= Partner.find(@partner_id)
      end

      def event
        partner.events.find_by!(organization_identifier: clean_organization_identifier)
      end

      def clean_organization_identifier
        @organization_identifier.to_s.strip
      end
    end
  end
end

