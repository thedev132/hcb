# frozen_string_literal: true

module EventJob
  class Create < ApplicationJob
    def perform(event_name, organizer_emails)
      attrs = {
        name: event_name,
        emails: organizer_emails,
        spend_only: true
      }
      ::EventService::Create.new(attrs).run
    end
  end
end
