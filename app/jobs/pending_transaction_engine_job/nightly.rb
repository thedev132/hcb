# frozen_string_literal: true

module PendingTransactionEngineJob
  class Nightly < ApplicationJob
    def perform
      #::PendingTransactionEngine::Nuke.new.run

      ::PendingTransactionEngine::Nightly.new.run
    end
  end
end
