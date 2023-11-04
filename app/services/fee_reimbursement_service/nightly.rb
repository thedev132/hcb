# frozen_string_literal: true

module FeeReimbursementService
  class Nightly
    def run
      rename_stripe_fee_reimbursement
      # Don't run job unless there are unprocessed FeeReimbursements
      return unless FeeReimbursement.unprocessed.present?

      FeeReimbursement.unprocessed.find_each(batch_size: 100) do |fee_reimbursement|
        raise ArgumentError, "must be an unprocessed fee reimbursement only" unless fee_reimbursement.unprocessed?

        amount_cents = fee_reimbursement.amount
        memo = fee_reimbursement.transaction_memo

        # FS Main -> FS Operating
        Increase::AccountTransfers.create(
          account_id: IncreaseService::AccountIds::FS_MAIN,
          destination_account_id: IncreaseService::AccountIds::FS_OPERATING,
          amount: amount_cents,
          description: "Stripe fee reimbursement"
        )

        # FS Operating -> FS Main
        Increase::AccountTransfers.create(
          account_id: IncreaseService::AccountIds::FS_OPERATING,
          destination_account_id: IncreaseService::AccountIds::FS_MAIN,
          amount: amount_cents,
          description: memo
        )

        fee_reimbursement.update_column(:processed_at, Time.now)
      end
    end

    def rename_stripe_fee_reimbursement
      stripe_fee_reimbursement_canonical_transactions_to_rename.update_all(custom_memo: "🗂️ Stripe fee reimbursement")
    end

    def stripe_fee_reimbursement_canonical_transactions_to_rename
      CanonicalTransaction.likely_fee_reimbursement.without_custom_memo
    end
  end
end
