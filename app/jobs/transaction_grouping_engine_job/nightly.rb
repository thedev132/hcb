# frozen_string_literal: true

module TransactionGroupingEngineJob
  class Nightly < ApplicationJob
    queue_as :low
    include ::TransactionEngine::Shared

    def perform
      ::TransactionGroupingEngine::Nightly.new(start_date: last_1_month).run
    end

  end
end
