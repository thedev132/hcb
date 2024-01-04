# frozen_string_literal: true

module DisbursementJob
  class Distribute128CollectiveFund < ApplicationJob
    queue_as :low
    def perform
      DisbursementService::Distribute128CollectiveFund.new.run
    end

  end
end
