module LedgerService
  class Event
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      # TODO
      transactions = []
    end

    private

    def event
      @event ||= Event.find(@event_id)
    end
  end
end
