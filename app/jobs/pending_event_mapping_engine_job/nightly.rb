# frozen_string_literal: true

module PendingEventMappingEngineJob
  class Nightly < ApplicationJob
    sidekiq_options retry: false # This is a job queued by sidekiq cron, so it's ok if we just wait for the next run

    def perform
      ::PendingEventMappingEngine::Nightly.new.run
    end
  end
end
