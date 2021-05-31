module BankFeeService
  class Create
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      raise ArgumentError, "must be an event that has not had a fee for more than 20 days" unless event.ready_for_fee?
      raise ArgumentError, "must be an event that has a balance greater than 0" unless event.fee_balance_v2_cents > 0

      ActiveRecord::Base.transaction do
        bank_fee = event.bank_fees.create!(attrs)

        event.update_column(:last_fee_processed_at, Time.now)

        bank_fee
      end
    end

    private

    def attrs
      {
        amount_cents: -calculate_amount_cents
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end

    def calculate_amount_cents
      event.fee_balance_v2_cents
    end
  end
end
