# frozen_string_literal: true

module DisbursementService
  class Nightly
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsOperatingToFsMain
    include ::Shared::Selenium::TransferFromFsMainToFsOperating

    def run
      # Don't run job unless there are pending Disbursements
      return unless Disbursement.pending.present?

      # 1. begin by navigating
      login_to_svb!

      Disbursement.pending.each do |disbursement|
        raise ArgumentError, "must be a pending disbursement only" unless disbursement.pending?

        amount_cents = disbursement.amount
        memo = disbursement.transaction_memo

        # Make the transfer in to Fiscal Sponsorship
        transfer_from_fs_main_to_fs_operating!(amount_cents: amount_cents, memo: memo)
        sleep 5 # helps simulate real clicking

        begin
          # Make the transfer out from Fiscal Sponsorship
          transfer_from_fs_operating_to_fs_main!(amount_cents: amount_cents, memo: memo)
        rescue => e
          # there was an error so mark this disbursement as in a bad/mixed state
          Airbrake.notify("Disbursement #{disbursement.id} in mixed/bad error state. Partially processed remotely. Investigate and fix by hand.")
          disbursement.update_column(:errored_at, Time.now)
          raise e
        end

        disbursement.update_column(:fulfilled_at, Time.now)

        sleep 5 # helps simulate real clicking
      end

      driver.quit
    end
  end
end
