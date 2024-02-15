# frozen_string_literal: true

module BankFeeService
  class ProcessSingle
    def initialize(bank_fee_id:)
      @bank_fee_id = bank_fee_id
    end

    def run
      raise ArgumentError, "must be a pending bank fee only" unless bank_fee.pending?

      ActiveRecord::Base.transaction do
        bank_fee.mark_in_transit!

        if amount_cents.negative?
          # Fiscal Sponsorship Fee
          sender_bank_account_id, receiver_bank_account_id = ColumnService::Accounts::FS_MAIN, ColumnService::Accounts::FS_OPERATING
        else
          # Fee credit
          sender_bank_account_id, receiver_bank_account_id = ColumnService::Accounts::FS_OPERATING, ColumnService::Accounts::FS_MAIN
        end

        ColumnService.post "/transfers/book",
                           amount: amount_cents.abs,
                           currency_code: "USD",
                           sender_bank_account_id:,
                           receiver_bank_account_id:,
                           description: memo
      end

      true
    end

    private

    def amount_cents
      bank_fee.amount_cents
    end

    def memo
      "HCB-#{local_hcb_code.short_code}"
    end

    def local_hcb_code
      @local_hcb_code ||= bank_fee.local_hcb_code
    end

    def bank_fee
      @bank_fee ||= BankFee.pending.find(@bank_fee_id)
    end

  end
end
