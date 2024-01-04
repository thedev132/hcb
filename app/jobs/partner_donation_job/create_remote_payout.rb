# frozen_string_literal: true

module PartnerDonationJob
  class CreateRemotePayout < ApplicationJob
    queue_as :default
    # Don't retry job, reattempt at next cron scheduled run
    discard_on(StandardError) do |job, error|
      Airbrake.notify(error)
    end

    def perform(partner_id, stripe_charge_id)
      ::PartnerDonationService::CreateRemotePayout.new(partner_id:, stripe_charge_id:).run
    end

  end
end
