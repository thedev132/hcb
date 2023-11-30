# frozen_string_literal: true

module ExportJob
  class Ledger < ApplicationJob
    def perform(event_id:, user_id:, email:)
      @event = Event.find(event_id)
      @user = user_id ? User.find(user_id) : nil

      datetime = Time.now.to_formatted_s(:db)
      title = "transaction_export_#{@event.name}_#{datetime}"
              .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
      title += ".ledger"

      ledger = CanonicalTransactionService::Export::Ledger.new(event_id:).run

      ExportMailer.export_ready(
        event: @event,
        email: @user.email || email,
        mime_type: "text/ledger",
        title:,
        content: ledger
      ).deliver_later
    end

  end
end
