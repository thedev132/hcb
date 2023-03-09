# frozen_string_literal: true

module CheckService
  class Create
    include ::Shared::AmpleBalance

    def initialize(event_id:,
                   lob_address_id:,
                   payment_for:, memo:, amount_cents_string:, send_date:,
                   current_user:)
      @event_id = event_id
      @lob_address_id = lob_address_id

      @payment_for = payment_for
      @memo = memo
      @amount_cents_string = amount_cents_string
      @send_date = send_date

      @current_user = current_user
    end

    def run
      raise ArgumentError, "You don't have enough money to write this check." unless ample_balance?(amount_cents, event)

      check = Check.create!(create_attrs)

      rpoct = RawPendingOutgoingCheckTransaction.create!(check_transaction_id: check.id.to_s, amount_cents: -check.amount, date_posted: check.created_at)
      cpt = CanonicalPendingTransaction.create!(
        date: rpoct.date,
        memo: rpoct.memo,
        amount_cents: rpoct.amount_cents,
        raw_pending_outgoing_check_transaction_id: rpoct.id,

        event: event
      )

      check
    end

    private

    def create_attrs
      {
        lob_address: lob_address,
        payment_for: @payment_for,
        memo: @memo,
        amount: amount_cents,
        send_date: @send_date,
        description: description,
        creator: @current_user
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end

    def lob_address
      @lob_address ||= event.lob_addresses.find(@lob_address_id)
    end

    def description
      @description ||= "#{event.name} - #{lob_address.name}"[0..255]
    end

    def amount_cents
      Monetize.parse(@amount_cents_string).cents
    end

  end
end
