# frozen_string_literal: true

module DonationJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      DonationService::Nightly.new.run
    end

  end
end
