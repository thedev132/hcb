# frozen_string_literal: true

module DisbursementService
  class Nightly
    def run
      return unless Disbursement.pending.present?

      Disbursement.pending.each do |disbursement|
        raise ArgumentError, "must be a pending disbursement only" unless disbursement.pending?

        amount_cents = disbursement.amount
        memo = disbursement.transaction_memo

        # FS Main -> FS Operating
        Increase::AccountTransfers.create(
          account_id: IncreaseService::AccountIds::FS_MAIN,
          destination_account_id: IncreaseService::AccountIds::FS_OPERATING,
          amount: amount_cents,
          description: memo
        )

        # FS Operating -> FS Main
        Increase::AccountTransfers.create(
          account_id: IncreaseService::AccountIds::FS_OPERATING,
          destination_account_id: IncreaseService::AccountIds::FS_MAIN,
          amount: amount_cents,
          description: memo
        )

        disbursement.mark_in_transit!
      end
    end

  end
end
