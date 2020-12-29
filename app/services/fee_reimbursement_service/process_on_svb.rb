module FeeReimbursementService
  class ProcessOnSvb
    def initialize(fee_reimbursement_id:)
      @fee_reimbursement_id = fee_reimbursement_id
    end

    def run
      raise ArgumentError, "must be an unprocessed fee reimbursement only" unless fee_reimbursement.unprocessed?

      SeleniumService::FeeReimbursement.new(memo: memo, amount: amount).run

      fee_reimbursement.update_column(:processed_at, Time.now)
    end

    private

    def fee_reimbursement
      @fee_reimbursement ||= FeeReimbursement.find(@fee_reimbursement_id)
    end

    def memo
      fee_reimbursement.transaction_memo
    end

    def amount
      fee_reimbursement.amount.to_f / 100
    end
  end
end
