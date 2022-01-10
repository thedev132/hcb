# frozen_string_literal: true

require "json"

module DonationService
  module Export
    class Json
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        event.donations.order("created_at desc").map do |donation|
          row(donation)
        end.to_json
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def row(ct)
        {
          status: ct.aasm_state,
          created_at: ct.created_at,
          url: "https://bank.hackclub.com/donations/#{ct.id}/",
          name: ct.name,
          amount: ct.amount
        }
      end

    end
  end
end
