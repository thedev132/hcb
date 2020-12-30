# frozen_string_literal: true

module FeeReimbursementJob
  class Nightly < ApplicationJob
    def perform
      FeeReimbursement.unprocessed.each do |fee_reimbursement_id|
        FeeReimbursementService::ProcessOnSvb.new(fee_reimbursement_id: fee_reimbursement_id).run
      end
    end
  end
end
