# frozen_string_literal: true

module EventMappingEngine
  module Map
    class Achs
      def run
        likely_achs.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::Ach.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end

        likely_increase_achs.find_each(batch_size: 100) do |ct|
          ach_transfer = ct.ach_transfer
          next unless ach_transfer

          ::CanonicalEventMapping.create!(canonical_transaction: ct, event: ach_transfer.event)
        end
      end

      private

      def likely_achs
        ::CanonicalTransaction.unmapped.likely_achs.order("date asc")
      end

      def likely_increase_achs
        ::CanonicalTransaction.unmapped.likely_increase_achs.order("date asc")
      end

    end
  end
end
