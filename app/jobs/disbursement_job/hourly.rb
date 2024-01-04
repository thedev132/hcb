# frozen_string_literal: true

module DisbursementJob
  class Hourly < ApplicationJob
    queue_as :default
    def perform
      DisbursementService::Hourly.new.run
    end

  end
end
