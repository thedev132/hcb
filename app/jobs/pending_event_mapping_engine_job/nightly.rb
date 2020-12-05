module PendingEventMappingEngineJob
  class Nightly < ApplicationJob
    def perform
      ::PendingEventMappingEngine::Nightly.new.run
    end
  end
end
