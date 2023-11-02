# frozen_string_literal: true

module CanonicalTransactionJob
  module Export
    class Ledger < ApplicationJob
      def perform(event_id:, user_id:)
        @event = Event.find(event_id)
        @user = User.find(user_id)

        datetime = Time.now.to_formatted_s(:db)
        title = "transaction_export_#{@event.name}_#{datetime}"
                .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
        title += ".ledger"

        ledger = CanonicalTransactionService::Export::Ledger.new(event_id:).run

        CanonicalTransactionMailer.export_ready(
          event: @event,
          user: @user,
          mime_type: "text/ledger",
          title:,
          content: ledger
        ).deliver_later
      end

    end
  end
end
