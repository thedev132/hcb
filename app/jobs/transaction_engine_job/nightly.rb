# frozen_string_literal: true

module TransactionEngineJob
  class Nightly < ApplicationJob
    include ::TransactionEngine::Shared

    def perform
      ::EventMappingEngine::Nuke.new.run
      #::TransactionEngine::Nuke.new.run

      ::TransactionEngine::Nightly.new(start_date: last_1_month).run
    end
  end
end
