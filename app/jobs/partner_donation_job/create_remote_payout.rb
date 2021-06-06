# frozen_string_literal: true

module PartnerDonationJob
  class CreateRemotePayout < ApplicationJob
    def perform(partner_id, stripe_charge_id)
      ::PartnerDonationService::CreateRemotePayout.new(partner_id: partner_id, stripe_charge_id: stripe_charge_id).run
    end
  end
end
