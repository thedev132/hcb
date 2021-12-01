# frozen_string_literal: true

module PendingTransactionEngineJob
  class Nightly < ApplicationJob
    include Sidekiq::Worker
    sidekiq_options retry: 1 # This is a job queued by sidekiq cron, so it's ok if we just wait for the next run

    def perform
      ::PendingTransactionEngine::Nightly.new.run
    end
  end
end
