# frozen_string_literal: true

module FeeReimbursementJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      FeeReimbursementService::Nightly.new.run
    end

  end
end
