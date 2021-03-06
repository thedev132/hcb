# frozen_string_literal: true

module AchTransferJob
  class Nightly < ApplicationJob
    def perform
      AchTransferService::Nightly.new.run
    end
  end
end
