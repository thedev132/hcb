# frozen_string_literal: true

module CanonicalTransactionJob
  module Export
    class Json < ApplicationJob
      def perform(event_id:, user_id:)
        @event = Event.find(event_id)
        @user = User.find(user_id)

        datetime = Time.now.to_formatted_s(:db)
        title = "transaction_export_#{@event.name}_#{datetime}"
                .gsub(/[^0-9a-z_]/i, '-').gsub(' ', '_')
        title += ".json"

        json = CanonicalTransactionService::Export::Json.new(event_id: event_id).run

        params = {
          event: @event,
          user: @user,
          mime_type: "application/json",
          title: title,
          content: json.to_s
        }
        CanonicalTransactionMailer.export_ready(params).deliver_later
      end

    end
  end
end
