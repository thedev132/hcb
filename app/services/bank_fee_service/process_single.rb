# frozen_string_literal: true

module BankFeeService
  class ProcessSingle
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsMainToFsOperating
    include ::Shared::Selenium::TransferFromFsOperatingToFsMain

    def initialize(bank_fee_id:, driver: nil)
      @bank_fee_id = bank_fee_id
      @driver = driver
      @already_logged_in = @driver.present?
    end

    def run
      raise ArgumentError, "must be a pending bank fee only" unless bank_fee.pending?

      ActiveRecord::Base.transaction do
        bank_fee.mark_in_transit!

        # 1. begin by navigating
        login_to_svb! unless @already_logged_in

        # Make the transfer on remote bank
        transfer_from_fs_main_to_fs_operating!(amount_cents: amount_cents, memo: memo)

        sleep 5 # helps simulate real clicking

        transfer_from_fs_operating_to_fs_main!(amount_cents: amount_cents, memo: incoming_memo)
      end

      sleep 5

      driver.quit unless @already_logged_in

      true
    end

    private

    def amount_cents
      bank_fee.amount_cents.abs # needs to use absolute positive value
    end

    def memo
      "HCB-#{local_hcb_code.short_code}"
    end

    def incoming_memo
      hcb_code = HcbCode.find_or_create_by(hcb_code: "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::INCOMING_BANK_FEE_CODE}-#{bank_fee.id}")
      "HCB-#{hcb_code.short_code}"
    end

    def local_hcb_code
      @local_hcb_code ||= bank_fee.local_hcb_code
    end

    def bank_fee
      @bank_fee ||= BankFee.pending.find(@bank_fee_id)
    end

  end
end
