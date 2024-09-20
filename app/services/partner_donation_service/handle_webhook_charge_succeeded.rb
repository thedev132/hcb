# frozen_string_literal: true

module PartnerDonationService
  class HandleWebhookChargeSucceeded
    def initialize(charge)
      @charge = charge
    end

    def run
      Airbrake.notify("PartnerDonationService::HandleWebhookChargeSucceeded ran")
    end

  end
end
