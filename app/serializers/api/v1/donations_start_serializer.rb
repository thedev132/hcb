# frozen_string_literal: true

module Api
  module V1
    class DonationsStartSerializer
      def initialize(partner_donation:)
        @partner_donation = partner_donation
      end

      def run
        {
          data: [data]
        }
      end

      private

      def data
        {
          organizationIdentifier: event.organization_identifier,
          donationIdentifier: @partner_donation.donation_identifier
        }
      end

      def event
        @partner_donation.event
      end
    end
  end
end
