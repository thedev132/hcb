# frozen_string_literal: true

module CheckJob
  class Nightly < ApplicationJob
    def perform
      CheckService::Nightly.new.run
    end
  end
end
