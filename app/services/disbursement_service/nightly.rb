# frozen_string_literal: true

module DisbursementService
  class Nightly
    def run
      return unless Disbursement.pending.present?

      Disbursement.pending.find_each(batch_size: 100) do |disbursement|
        raise ArgumentError, "must be a pending disbursement only" unless disbursement.pending?

        amount_cents = disbursement.amount
        memo = disbursement.transaction_memo

        if disbursement.destination_event.increase_account_id != disbursement.source_event.increase_account_id
          Increase::AccountTransfers.create(
            account_id: disbursement.source_event.increase_account_id,
            destination_account_id: disbursement.destination_event.increase_account_id,
            amount: amount_cents,
            description: memo
          )
        else
          # events are on the same Increase account

          Increase::AccountTransfers.create(
            account_id: disbursement.source_event.increase_account_id,
            destination_account_id: IncreaseService::AccountIds::FS_OPERATING,
            amount: amount_cents,
            description: memo
          )

          # FS Operating -> FS Main
          Increase::AccountTransfers.create(
            account_id: IncreaseService::AccountIds::FS_OPERATING,
            destination_account_id: disbursement.source_event.increase_account_id,
            amount: amount_cents,
            description: memo
          )
        end


        disbursement.mark_in_transit!
      end
    end

  end
end
