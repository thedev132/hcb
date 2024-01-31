# frozen_string_literal: true

module OneTimeJobs
  class BackfillDisbursementShouldChargeFee
    def self.run
      # backfill `Disbursement#should_charge_fee` for disbursements that had their fees un-waived
      disbursement_ids = CanonicalTransaction.disbursement_hcb_code.includes(:fee).where(fee: { reason: "REVENUE" }).pluck(:hcb_code).map { |hcb_code| hcb_code.split("-").last }
      Disbursement.where(id: disbursement_ids).update_all(should_charge_fee: true)

      # backfill `CanonicalPendingTransaction#fee_waived` for disbursement transactions
      canonical_pending_transaction_ids = Disbursement.where(should_charge_fee: false).includes(raw_pending_incoming_disbursement_transaction: :canonical_pending_transaction).map { |d| d.raw_pending_incoming_disbursement_transaction.canonical_pending_transaction.id }
      CanonicalPendingTransaction.where(id: canonical_pending_transaction_ids).update_all(fee_waived: true)
    end

  end
end
