# frozen_string_literal: true

module EventMappingEngine
  module Map
    class Checks
      def run
        likely_checks.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::Check.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_checks
        ::CanonicalTransaction.unmapped.likely_checks.order("date asc")
      end

    end
  end
end
