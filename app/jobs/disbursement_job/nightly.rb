# frozen_string_literal: true

module DisbursementJob
  class Nightly < ApplicationJob
    def perform
      DisbursementService::Nightly.new.run
    end
  end
end
