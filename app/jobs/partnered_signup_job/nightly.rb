# frozen_string_literal: true

module PartneredSignupJob
  class Nightly < ApplicationJob
    def perform
      ::PartneredSignupService::Nightly.new.run
    end

  end
end
