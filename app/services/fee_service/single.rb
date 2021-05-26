module FeeService
  class Single
    include ::Shared::Selenium::LoginToSvb
    include ::Shared::Selenium::TransferFromFsMainToFsOperating
    include ::Shared::Fee::CanonicalFeeMemo

    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      # 1. begin by navigating
      login_to_svb!

      # v2
      raise ArgumentError, "must be an event that has not had a fee for more than 20 days" unless event.ready_for_fee?
      raise ArgumentError, "must be an event that has a balance greater than 0" unless event.fee_balance_v2_cents > 0

      amount_cents = event.fee_balance_v2_cents
      memo = canonical_fee_memo(event: event)

      # Make the transfer on remote bank
      transfer_from_fs_main_to_fs_operating!(amount_cents: amount_cents, memo: memo)

      event.update_column(:last_fee_processed_at, Time.now)

      sleep 5 # helps simulate real clicking

      driver.quit
    end

    private

    def event
      @event ||= Event.pending_fees_v2.find(@event_id)
    end
  end
end
