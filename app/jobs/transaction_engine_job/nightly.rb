# frozen_string_literal: true

module TransactionEngineJob
  class Nightly < ApplicationJob
    def perform
      ::EventMappingEngine::Nuke.new.run
      #::TransactionEngine::Nuke.new.run

      ::TransactionEngine::Nightly.new(start_date: last_month).run
    end

    private

    def last_month
      Time.now.utc - 1.months
    end
  end
end
