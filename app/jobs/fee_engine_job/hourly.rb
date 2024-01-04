# frozen_string_literal: true

module FeeEngineJob
  class Hourly < ApplicationJob
    queue_as :default
    def perform
      ::FeeEngine::Hourly.new.run
    end

  end
end
