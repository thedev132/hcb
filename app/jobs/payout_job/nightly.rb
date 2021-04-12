# frozen_string_literal: true

module PayoutJob
  class Nightly < ApplicationJob
    def perform
      ::PayoutService::Nightly.new.run
    end
  end
end
