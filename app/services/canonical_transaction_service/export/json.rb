# frozen_string_literal: true

require "json"

module CanonicalTransactionService
  module Export
    class Json
      def initialize(event_id:)
        @event_id = event_id
      end

      # NOTE: technicall not streaming at this time
      def run
        event.canonical_transactions.order("date desc").map do |ct|
          row(ct)
        end.to_json
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def row(ct)
        {
          date: ct.date,
          memo: ct.local_hcb_code.memo,
          amount_cents: ct.amount_cents,
          tags: ct.local_hcb_code.tags.filter { |tag| tag.event_id == @event_id }.pluck(:label).join(", ")
        }
      end

    end
  end
end
