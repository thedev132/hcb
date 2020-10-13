module EventMappingEngine
  module Map
    class Github
      def run
        likely_githubs.find_each do |ct|
          guessed_event_id = ::EventMappingEngine::GuessEventId::Github.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_githubs
        ::CanonicalTransaction.awaiting_match.likely_github
      end

    end
  end
end
