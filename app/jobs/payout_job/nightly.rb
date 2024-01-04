# frozen_string_literal: true

module PayoutJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      ::PayoutService::Nightly.new.run
    end

  end
end
