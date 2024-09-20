# frozen_string_literal: true

module PartnerDonationService
  class Import
    def initialize(partner_id:)
      @partner_id = partner_id
    end

    def run
      Airbrake.notify("PartnerDonationService::Import")
    end

  end
end
