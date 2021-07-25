# frozen_string_literal: true

module EventMappingEngine
  module GuessEventId
    class StripeTopUp
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        999 # Hack Club NoEvent
      end
    end
  end
end
