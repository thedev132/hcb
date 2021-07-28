# frozen_string_literal: true

module EventService
  class Reject
    def initialize(event)
      @event = event
    end

    def run
      @event.mark_rejected!

      # deliver a webhook to let our Partner know the organization's status has updated
      ::EventJob::DeliverWebhook.perform_later(@event.id)

      @event.aasm.current_state
    end

    private

  end
end
