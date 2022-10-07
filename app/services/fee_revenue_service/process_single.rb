# frozen_string_literal: true

module FeeRevenueService
  class ProcessSingle
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsOperatingToFsMain

    def initialize(fee_revenue_id:, driver: nil)
      @fee_revenue_id = fee_revenue_id
      @driver = driver
      @already_logged_in = @driver.present?
    end

    def run
      raise ArgumentError, "must be pending fee revenue only" unless fee_revenue.pending?

      ActiveRecord::Base.transaction do
        fee_revenue.mark_in_transit!

        # 1. begin by navigating
        login_to_svb! unless @already_logged_in

        # Make the transfer on remote bank
        transfer_from_fs_operating_to_fs_main!(amount_cents: amount_cents, memo: memo)
      end

      sleep 5

      driver.quit unless @already_logged_in

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
