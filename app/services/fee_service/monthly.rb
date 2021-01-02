module FeeService
  class Monthly
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsMainToFsOperating
    include ::Shared::Fee::CanonicalFeeMemo

    def run
      # 1. begin by navigating
      login_to_svb!

      Event.pending_fees_v2.each do |event|
        raise ArgumentError, "must be an event that has not had a fee for more than 20 days" unless event.ready_for_fee?

        amount_cents = event.fee_balance_v2_cents
        memo = canonical_fee_memo(event: event)

        # Make the transfer on remote bank
        transfer_from_fs_main_to_fs_operating!(amount_cents: amount_cents, memo: memo)

        event.update_column(:last_fee_processed_at, Time.now)

        sleep 5 # helps simulate real clicking
      end

      driver.quit
    end

    private

  end
end
