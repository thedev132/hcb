# frozen_string_literal: true

module FeeRevenueService
  class ProcessSingle
    include IncreaseService::AccountIds

    def initialize(fee_revenue_id:)
      @fee_revenue_id = fee_revenue_id
    end

    def run
      raise ArgumentError, "must be pending fee revenue only" unless fee_revenue.pending?

      increase = IncreaseService.new

      ActiveRecord::Base.transaction do
        fee_revenue.mark_in_transit!

        increase.transfer from: fs_operating_account_id, to: fs_main_account_id, amount: amount_cents, memo: memo
      end

      true
    end

    private

    def amount_cents
      fee_revenue.amount_cents
    end

    def memo
      "HCB-#{local_hcb_code.short_code}"
    end

    def local_hcb_code
      @local_hcb_code ||= fee_revenue.local_hcb_code
    end

    def fee_revenue
      @fee_revenue ||= FeeRevenue.pending.find(@fee_revenue_id)
    end

  end
end
