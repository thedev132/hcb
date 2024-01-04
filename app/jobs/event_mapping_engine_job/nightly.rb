# frozen_string_literal: true

module EventMappingEngineJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      ::EventMappingEngine::Nightly.new.run
    end

  end
end
