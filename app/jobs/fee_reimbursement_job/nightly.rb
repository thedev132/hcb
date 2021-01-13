# frozen_string_literal: true

module FeeReimbursementJob
  class Nightly < ApplicationJob
    def perform
      FeeReimbursementService::Nightly.new.run
    end
  end
end
