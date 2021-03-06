module EventMappingEngine
  module Map
    class HackClubBankIssuedCards
      def run
        likely_hack_club_bank_issued_cards.find_each(batch_size: 100) do |ct|
          guessed_event_id = ::EventMappingEngine::GuessEventId::HackClubBankIssuedCard.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_hack_club_bank_issued_cards
        ::CanonicalTransaction.unmapped.likely_hack_club_bank_issued_cards.order("date asc")
      end

    end
  end
end
