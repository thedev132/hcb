# frozen_string_literal: true

module PartneredSignupJob
  class Nightly < ApplicationJob
    # Don't retry job, reattempt at next cron scheduled run
    discard_on(StandardError) do |job, error|
      Airbrake.notify(error)
    end

    def perform
      ::PartneredSignupService::Nightly.new.run
    end

  end
end
