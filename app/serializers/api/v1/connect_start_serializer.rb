# frozen_string_literal: true

module Api
  module V1
    class ConnectStartSerializer
      def initialize(event:)
        @event = event
      end

      def run
        {
          data: [ data ]
        }
      end

      private

      def data
        {
          organizationIdentifier: @event.organization_identifier,
          redirect_url: @event.redirect_url,
          status: @event.aasm_state,
          connectUrl: connect_url
        }
      end

      def connect_url
        Rails.application.routes.url_helpers.api_connect_continue_api_v1_index_url(hashid: @event.hashid)
      end
    end
  end
end
