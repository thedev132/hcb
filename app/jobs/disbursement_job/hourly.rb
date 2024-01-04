# frozen_string_literal: true

module DisbursementJob
  class Hourly < ApplicationJob
    queue_as :low
    def perform
      DisbursementService::Hourly.new.run
    end

  end
end
