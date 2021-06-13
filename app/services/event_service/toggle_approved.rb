module EventService
  class ToggleApproved
    def initialize(event)
      @event = event
    end

    def run
      state = toggle

      # deliver a webhook to let our Partner know the organization's status has updated
      ::EventJob::DeliverWebhook.perform_later(@event.id)

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
