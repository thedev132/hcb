module EventService
  class ToggleApproved
    def initialize(event)
      @event = event
    end

    def run
      if @event.approved?
        @event.mark_pending!
      else
        @event.mark_approved!
      end

      state = @event.aasm.current_state

      # deliver a webhook to let our Partner know the organization's status has updated
      ::EventJob::DeliverWebhook.perform_later(@event.id)

      state
    end

    private

  end
end
