# frozen_string_literal: true

module CheckJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      CheckService::Nightly.new.run
    end

  end
end
