# frozen_string_literal: true

module DisbursementService
  class Reject
    def initialize(disbursement_id:, fulfilled_by_id:)
      @disbursement = Disbursement.find disbursement_id
      @fulfilled_by = User.find fulfilled_by_id
    end

    def run
      raise ArgumentError, "Disbursement is already processed" unless @disbursement.reviewing?

      @disbursement.update_attributes(attrs)
      @disbursement
    end

    private

    def attrs
      {
        rejected_at: DateTime.now,
        fulfilled_by: @fulfilled_by
      }
    end

  end
end
