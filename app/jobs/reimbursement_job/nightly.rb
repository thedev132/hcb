# frozen_string_literal: true

module ReimbursementJob
  class Nightly < ApplicationJob
    queue_as :low
    def perform
      Reimbursement::ExpensePayoutService::Nightly.new.run
      Reimbursement::PayoutHoldingService::Nightly.new.run
    end

  end
end
