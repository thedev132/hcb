# frozen_string_literal: true

module Api
  module V1
    class OrganizationSerializer
      def initialize(event:)
        @event = event
      end

      def run
        {
          data: [data]
        }
      end

      private

      def data # this method is also used by Api::V1::OrganizationSerializer
        {
          organizationIdentifier: @event.organization_identifier,
          status: @event.aasm_state,
          balance: @event.balance_v2_cents,
        }
      end
    end
  end
end
