# frozen_string_literal: true

module DisbursementService
  class Create
    include ::Shared::AmpleBalance

    def initialize(source_event_id:, destination_event_id:,
                   name:, amount:, requested_by_id:, fulfilled_by_id: nil)
      @source_event_id = source_event_id
      @source_event = Event.friendly.find(@source_event_id)
      @destination_event_id = destination_event_id
      @destination_event = Event.friendly.find(@destination_event_id)
      @name = name
      @amount = amount
      @requested_by_id = requested_by_id
      @fulfilled_by_id = fulfilled_by_id
    end

    def run
      raise ArgumentError, "amount is required" unless @amount
      raise ArgumentError, "amount_cents must be greater than 0" unless amount_cents > 0
      raise ArgumentError, "You don't have enough money to make this disbursement." unless ample_balance?(amount_cents, @source_event) || requested_by.admin?

      disbursement = Disbursement.create!(attrs)

      if requested_by.admin?
        DisbursementService::Approve.new(
          disbursement_id: disbursement.id,
          fulfilled_by_id: requested_by.id
        ).run
      end

      disbursement
    end

    private

    def attrs
      {
        source_event_id: source_event.id,
        event_id: destination_event.id,
        name: @name,
        amount: amount_cents,
        requested_by: requested_by
      }
    end

    def requested_by
      @requested_by ||= User.find @requested_by_id
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
