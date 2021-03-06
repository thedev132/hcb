module DisbursementService
  class Create
    def initialize(source_event_id:, destination_event_id:,
                   name:, amount:)
      @source_event_id = source_event_id
      @destination_event_id = destination_event_id
      @name = name
      @amount = amount
    end

    def run
      raise ArgumentError, "amount is required" unless @amount
      raise ArgumentError, "amount_cents must be greater than 0" unless amount_cents > 0

      Disbursement.create!(attrs)
    end

    private

    def attrs
      {
        source_event_id: source_event.id,
        event_id: destination_event.id,
        name: @name,
        amount: amount_cents
      }
    end

    def amount_cents
      @amount_cents ||= @amount.to_s.gsub(",", "").to_f * 100
    end

    def source_event
      @source_event ||= Event.find(@source_event_id)
    end

    def destination_event
      @destination_event ||= Event.find(@destination_event_id)
    end
  end
end
