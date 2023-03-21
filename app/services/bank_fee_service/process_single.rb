# frozen_string_literal: true

module BankFeeService
  class ProcessSingle
    include IncreaseService::AccountIds

    def initialize(bank_fee_id:)
      @bank_fee_id = bank_fee_id
    end

    def run
      raise ArgumentError, "must be a pending bank fee only" unless bank_fee.pending?

      increase = IncreaseService.new

      ActiveRecord::Base.transaction do
        bank_fee.mark_in_transit!

        increase.transfer from: fs_main_account_id, to: fs_operating_account_id, amount: amount_cents, memo: memo
      end

      true
    end

    private

    def amount_cents
      bank_fee.amount_cents.abs # needs to use absolute positive value
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
