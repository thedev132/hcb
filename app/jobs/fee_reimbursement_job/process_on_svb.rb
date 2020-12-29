# frozen_string_literal: true

module FeeReimbursementJob
  class ProcessOnSvb < ApplicationJob
    def perform(fee_reimbursement_id)
      FeeReimbursementService::ProcessOnSvb.new(fee_reimbursement_id: fee_reimbursement_id).run
    end
  end
end
