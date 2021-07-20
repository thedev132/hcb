# frozen_string_literal: true

module PartnerDonationService
  class Nightly
    def run
      ::Partner.all do |partner|
        ::PartnerDonationService::Import.new(partner_id: partner.id).run
      end
    end
  end
end
