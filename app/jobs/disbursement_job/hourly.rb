# frozen_string_literal: true

module DisbursementJob
  class Hourly < ApplicationJob
    def perform
      DisbursementService::Hourly.new.run
    end

  end
end
