# frozen_string_literal: true

module FeeRevenueService
  class ProcessSingle
    def initialize(fee_revenue_id:)
      @fee_revenue_id = fee_revenue_id
    end

    def run
      raise ArgumentError, "must be pending fee revenue only" unless fee_revenue.pending?

      ActiveRecord::Base.transaction do
        fee_revenue.mark_in_transit!

        Increase::AccountTransfers.create(
          account_id: IncreaseService::AccountIds::FS_OPERATING,
          destination_account_id: IncreaseService::AccountIds::FS_MAIN,
          amount: amount_cents,
          description: memo
        )
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
