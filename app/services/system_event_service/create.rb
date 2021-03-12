# frozen_string_literal: true

module SystemEventService
  class Create
    VALID_EVENT_NAMES = [
      SystemEventService::Write::PendingTransactionCreated::NAME,
      SystemEventService::Write::SettledTransactionCreated::NAME,
      SystemEventService::Write::SettledTransactionMapped::NAME
    ]

    def initialize(name:, properties:)
      @name = name
      @properties = properties
    end

    def run
      raise ArgumentError, "invalid system event name #{@name}" unless valid_event_name?

      Ahoy::Event.create!(attrs)
    end

    private

    def attrs
      {
        name: @name,
        properties: @properties,
        time: Time.now
      }
    end

    def valid_event_name?
      VALID_EVENT_NAMES.include?(@name)
    end
  end
end
