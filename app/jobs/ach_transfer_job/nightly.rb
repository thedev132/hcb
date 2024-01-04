# frozen_string_literal: true

module AchTransferJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      AchTransferService::Nightly.new.run
    end

  end
end
