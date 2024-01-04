# frozen_string_literal: true

module DisbursementJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      DisbursementService::Nightly.new.run
    end

  end
end
