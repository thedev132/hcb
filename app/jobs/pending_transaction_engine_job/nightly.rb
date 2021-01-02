# frozen_string_literal: true

module PendingTransactionEngineJob
  class Nightly < ApplicationJob
    def perform
      ::PendingEventMappingEngine::Nuke.new.run
      #::PendingTransactionEngine::Nuke.new.run

      ::PendingTransactionEngine::Nightly.new.run
    end
  end
end
