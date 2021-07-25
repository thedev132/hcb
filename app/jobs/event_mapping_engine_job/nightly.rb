# frozen_string_literal: true

module EventMappingEngineJob
  class Nightly < ApplicationJob
    def perform
      ::EventMappingEngine::Nightly.new.run
    end
  end
end
