# frozen_string_literal: true

module TransactionEngineJob
  class Nightly < ApplicationJob
    def perform
      ::EventMappingEngine::Nuke.new.run
      ::TransactionEngine::Nuke.new.run

      ::TransactionEngine::Nightly.new.run
    end
  end
end
