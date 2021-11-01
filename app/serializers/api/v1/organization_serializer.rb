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
          id: @event.public_id,
          name: @event.name,
          balance: @event.balance_v2_cents
        }
      end
    end
  end
end
