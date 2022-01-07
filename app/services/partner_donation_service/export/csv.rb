# frozen_string_literal: true

require "csv"

module PartnerDonationService
  module Export
    class Csv
      BATCH_SIZE = 1000

      include PartnerDonationService::Export::Shared

      def run
        Enumerator.new do |y|
          y << headers.to_s

          partner_donations.each do |pd|
            y << row(pd).to_s
          end
        end
      end

      private

      def headers
        ::CSV::Row.new(keys, keys, true)
      end

      def row(pd)
        ::CSV::Row.new(keys, create_row(pd))
      end
    end
  end
end
