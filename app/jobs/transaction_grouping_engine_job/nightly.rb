# frozen_string_literal: true

module TransactionGroupingEngineJob
  class Nightly < ApplicationJob
    include ::TransactionEngine::Shared

    def perform
      ::TransactionGroupingEngine::Nightly.new(start_date: last_1_month).run
    end
  end
end
