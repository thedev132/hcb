# frozen_string_literal: true

module Api
  module V1
    class OrganizationSerializer
      def initialize(event:)
        @event = event
      end

      def run
        {
          data: [ data ],
        }
      end

      def data # this method is also used by Api::V1::OrganizationSerializer
        {
          organizationIdentifier: @event.organization_identifier,
          status: @event.aasm_state,
        }
      end

      private
    end
  end
end
