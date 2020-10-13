# frozen_string_literal: true

module TransactionEngineJob
  class Nightly < ApplicationJob
    def perform
      ::TransactionEngine::Nightly.new.run
    end
  end
end
