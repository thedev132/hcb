# frozen_string_literal: true

module PendingTransactionEngineJob
  class Nightly < ApplicationJob
    # Don't retry job, reattempt at next cron scheduled run
    discard_on Exception do |job, error|
      Airbrake.notify(error)
    end

    def perform
      ::PendingTransactionEngine::Nightly.new.run
    end
  end
end
