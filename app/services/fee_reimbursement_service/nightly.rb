module FeeReimbursementService
  class Nightly
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsOperatingToFsMain

    def run
      # 1. begin by navigating
      login_to_svb!

      FeeReimbursement.unprocessed.each do |fee_reimbursement|
        raise ArgumentError, "must be an unprocessed fee reimbursement only" unless fee_reimbursement.unprocessed?

        amount_cents = fee_reimbursement.amount
        memo = fee_reimbursement.transaction_memo

        # Make the transfer on remote bank
        transfer_from_fs_operating_to_fs_main!(amount_cents: amount_cents, memo: memo)

        fee_reimbursement.update_column(:processed_at, Time.now)

        sleep 5 # helps simulate real clicking
      end

      driver.quit
    end
  end
end
