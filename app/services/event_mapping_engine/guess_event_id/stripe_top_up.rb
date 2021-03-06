module EventMappingEngine
  module GuessEventId
    class StripeTopUp
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        183 # Hack Club HQ
      end
    end
  end
end
