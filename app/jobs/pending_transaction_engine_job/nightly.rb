# frozen_string_literal: true

module PendingTransactionEngineJob
  class Nightly < ApplicationJob
    sidekiq_options retry: false # This is a job queued by sidekiq cron, so it's ok if we just wait for the next run

    def perform
      ::PendingTransactionEngine::Nightly.new.run
    end
  end
end
