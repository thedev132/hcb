# frozen_string_literal: true

module DisbursementService
  class Approve
    def initialize(disbursement_id:, fulfilled_by_id:)
      @disbursement = Disbursement.find disbursement_id
      @fulfilled_by = User.find fulfilled_by_id
    end

    def run
      raise ArgumentError, "Disbursement is already processed" unless @disbursement.reviewing?

      ActiveRecord::Base.transaction do
        @disbursement.mark_approved!(@fulfilled_by)

        # Front the pending transactions
        @disbursement.canonical_pending_transactions.each do |cpt|
          cpt.update(fronted: true)
        end
      end

      @disbursement
    end

  end
end
