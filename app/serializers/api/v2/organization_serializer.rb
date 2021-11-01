# frozen_string_literal: true

module Api
  module V2
    class OrganizationSerializer
      def initialize(event:)
        @event = event
      end

      def run
        {
          data: data
        }
      end

      def data # this method is also used by Api::V2::OrganizationSerializer
        {
          id: @event.public_id,
          name: @event.name,
          balance: @event.balance_v2_cents
        }
      end
    end
  end
end
