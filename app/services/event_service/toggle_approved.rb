module EventService
  class ToggleApproved
    def initialize(event)
      @event = event
    end

    def run
      state = toggle

      # TODO: notify webhook (job)

      state
    end

    private

    def toggle
      if @event.approved?
        @event.mark_pending!
      else
        @event.mark_approved!
      end

      return @event.aasm.current_state
    end

  end
end
