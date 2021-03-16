# frozen_string_literal: true

module DonationJob
  class Nightly < ApplicationJob
    def perform
      DonationService::Nightly.new.run
    end
  end
end
