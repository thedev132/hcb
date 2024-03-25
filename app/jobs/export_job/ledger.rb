# frozen_string_literal: true

module ExportJob
  class Ledger < ApplicationJob
    queue_as :default
    def perform(event_id:, email:, public_only: false)
      @event = Event.find(event_id)

      datetime = Time.now.to_formatted_s(:db)
      title = "transaction_export_#{@event.name}_#{datetime}"
              .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
      title += ".ledger"

      ledger = ExportService::Ledger.new(event_id:, public_only:).run

      ExportMailer.export_ready(
        event: @event,
        email:,
        mime_type: "text/ledger",
        title:,
        content: ledger
      ).deliver_later
    end

  end
end
