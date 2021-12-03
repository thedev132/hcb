# frozen_string_literal: true

module PendingEventMappingEngineJob
  class Nightly < ApplicationJob
    def perform
      ::PendingEventMappingEngine::Nightly.new.run
    end
  end
end
