module CheckService
  class Create
    def initialize(event_id:,
                   lob_address_id:,
                   memo:, amount_cents:, send_date:,
                   current_user:)
      @event_id = event_id
      @lob_address_id = lob_address_id

      @memo = memo
      @amount_cents = amount_cents
      @send_date = send_date

      @current_user = current_user
    end

    def run
      raise ArgumentError, "You don't have enough money to write this check." unless ample_balance?

      ActiveRecord::Base.transaction do
        check = Check.create!(create_attrs)

        lob_check = Partners::Lob::Checks::Create.new(lob_attrs).run

        check.update_columns(update_attrs(lob_check: lob_check))
      end
    end

    private

    def create_attrs
      {
        lob_address: lob_address,
        memo: @memo,
        amount: @amount_cents,
        send_date: @send_date,
        description: description,
        creator: @current_user
      }
    end

    def lob_attrs
      {
        to: lob_address.lob_id,
        memo: @memo,
        amount_cents: @amount_cents,
        send_date: @send_date,
        description: description,
        message: message
      }
    end

    def update_attrs(lob_check:)
      transaction_memo = "#{lob_check["check_number"]} Check"[0..30]

      {
        lob_id: lob_check["id"],
        check_number: lob_check["check_number"],
        transaction_memo: transaction_memo,
        expected_delivery_date: lob_check["expected_delivery_date"]
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end

    def lob_address
      @lob_address ||= event.lob_addresses.find(@lob_address_id)
    end

    def message
      "This check was sent by The Hack Foundation on behalf of #{event.name}. #{event.name} is fiscally sponsored by the Hack Foundation (d.b.a Hack Club), a 501(c)(3) nonprofit with the EIN 81-2908499"
    end

    def ample_balance?
      event.balance_available_v2_cents >= @amount_cents
    end

    def description
      @description ||= "#{event.name} - #{lob_address.name}"[0..255]
    end
  end
end
