# frozen_string_literal: true

module CanonicalTransactionJob
  module Export
    class Csv < ApplicationJob
      def perform(event_id:, user_id:)
        @event = Event.find(event_id)
        @user = User.find(user_id)

        datetime = Time.now.to_formatted_s(:db)
        title = "transaction_export_#{@event.name}_#{datetime}"
                .gsub(/[^0-9a-z_]/i, "-").gsub(" ", "_")
        title += ".csv"

        csv_enumerator = CanonicalTransactionService::Export::Csv.new(event_id: event_id).run
        csv = csv_enumerator.reduce(:+)

        CanonicalTransactionMailer.export_ready(
          event: @event,
          user: @user,
          mime_type: "text/csv",
          title: title,
          content: csv
        ).deliver_later
      end

    end
  end
end
