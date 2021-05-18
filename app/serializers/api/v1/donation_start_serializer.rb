# frozen_string_literal: true

module Api
  module V1
    class DonationStartSerializer
      def initialize(donation:)
        @donation = donation
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        {
          organizationIdentifier: event.organization_identifier,
          donationIdentifier: donation.donation_identifier
        }
      end

      def event
        @donation.event
      end
    end
  end
end
