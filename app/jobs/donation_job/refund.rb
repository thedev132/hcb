# frozen_string_literal: true

module DonationJob
  class Refund < ApplicationJob
    def perform(donation_id)
      ::DonationService::Refund.new(donation_id: donation_id).run
    end
  end
end
