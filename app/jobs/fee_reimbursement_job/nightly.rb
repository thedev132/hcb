# frozen_string_literal: true

module FeeReimbursementJob
  class Nightly < ApplicationJob
    def perform
      FeeReimbursement.unprocessed.each do |fr|
        FeeReimbursementJob::ProcessOnSvb.perform(fr.id)
      end
    end
  end
end
