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
          memo: ct.smart_memo,
          amount_cents: ct.amount_cents
        }
      end
    end
  end
end
