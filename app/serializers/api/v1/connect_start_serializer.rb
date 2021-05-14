# frozen_string_literal: true

module Api
  module V1
    class ConnectStartSerializer
      def initialize(event:)
        @event = event
      end

      def run
        {
          data: data
        }
      end

      private

      def data
        {
          organizationIdentifier: @event.organization_identifier,
          redirect_url: @event.redirect_url,
          status: @event.aasm_state
        }
      end
    end
  end
end
