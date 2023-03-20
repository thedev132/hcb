# frozen_string_literal: true

module DisbursementService
  class Nightly
    include IncreaseService::AccountIds

    def run
      return unless Disbursement.pending.present?

      Disbursement.pending.each do |disbursement|
        raise ArgumentError, "must be a pending disbursement only" unless disbursement.pending?

        amount_cents = disbursement.amount
        memo = disbursement.transaction_memo

        increase = IncreaseService.new

        increase.transfer from: fs_main_account_id, to: fs_operating_account_id, amount: amount_cents, memo: memo
        increase.transfer from: fs_operating_account_id, to: fs_main_account_id, amount: amount_cents, memo: memo

        disbursement.mark_in_transit!
      end
    end

  end
end
