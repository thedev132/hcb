# frozen_string_literal: true

module ExportJob
  class Json < ApplicationJob
    def perform(event_id:, email:)
      @event = Event.find(event_id)

      datetime = Time.now.to_formatted_s(:db)
      title = "transaction_export_#{@event.name}_#{datetime}"
              .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
      title += ".json"

      json = CanonicalTransactionService::Export::Json.new(event_id:).run

      ExportMailer.export_ready(
        event: @event,
        email:,
        mime_type: "application/json",
        title:,
        content: json.to_s
      ).deliver_later
    end

  end
end
