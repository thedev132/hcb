# frozen_string_literal: true

module EventMappingEngine
  module GuessEventId
    class StripeTopUp
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        EventMappingEngine::EventIds::NOEVENT
      end

    end
  end
end
