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
        ::CanonicalTransaction.exclude(excluded_ids).likely_github
      end

      def excluded_ids
        @excluded_ids ||= ::CanonicalEventMapping.pluck(:canonical_transaction_id)
      end

    end
  end
end
