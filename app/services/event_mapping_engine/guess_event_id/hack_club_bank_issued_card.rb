# frozen_string_literal: true

module EventMappingEngine
  module GuessEventId
    class HackClubBankIssuedCard
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        636 # Hack Club Bank
      end
    end
  end
end
