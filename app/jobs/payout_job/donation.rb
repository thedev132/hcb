# frozen_string_literal: true

module PayoutJob
  class Donation < ApplicationJob
    def perform(donation_id)
      ::PayoutService::Donation::Create.new(donation_id: donation_id).run
    end
  end
end
