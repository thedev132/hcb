# frozen_string_literal: true

module ExportJob
  class Csv < ApplicationJob
    def perform(event_id:, email:)
      @event = Event.find(event_id)

      datetime = Time.now.to_formatted_s(:db)
      title = "transaction_export_#{@event.name}_#{datetime}"
              .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
      title += ".csv"

      csv_enumerator = ExportService::Csv.new(event_id:).run
      csv = csv_enumerator.reduce(:+)

      ExportMailer.export_ready(
        event: @event,
        email:,
        mime_type: "text/csv",
        title:,
        content: csv
      ).deliver_later
    end

  end
end
