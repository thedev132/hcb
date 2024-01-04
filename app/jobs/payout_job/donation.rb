# frozen_string_literal: true

module PayoutJob
  class Donation < ApplicationJob
    queue_as :default
    def perform(donation_id)
      ::PayoutService::Donation::Create.new(donation_id:).run
    end

  end
end
