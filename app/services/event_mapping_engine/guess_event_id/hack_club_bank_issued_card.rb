# frozen_string_literal: true

module EventMappingEngine
  module GuessEventId
    class HackClubBankIssuedCard
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        EventMappingEngine::EventIds::HACK_CLUB_BANK
      end

    end
  end
end
