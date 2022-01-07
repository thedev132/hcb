# frozen_string_literal: true

require "json"

module PartnerDonationService
  module Export
    class Json

      include PartnerDonationService::Export::Shared

      def run
        partner_donations.map do |pd|
          row(pd)
        end.to_json
      end

      private

      def row(pd)
        Hash[keys.zip(create_row(pd))]
      end
    end
  end
end
