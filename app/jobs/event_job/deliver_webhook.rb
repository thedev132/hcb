# frozen_string_literal: true

module EventJob
  class DeliverWebhook < ApplicationJob
    def perform(event_id)
      ::EventService::DeliverWebhook.new(event_id: event_id).run
    end
  end
end
