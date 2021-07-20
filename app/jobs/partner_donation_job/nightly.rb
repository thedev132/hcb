# frozen_string_literal: true

module PartnerDonationJob
  class Nightly < ApplicationJob
    def perform
      ::PartnerDonationService::Nightly.new.run
    end
  end
end
