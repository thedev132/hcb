module EventMappingEngine
  module Map
    class Donations
      def run
        likely_donations.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::Donation.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_donations
        ::CanonicalTransaction.unmapped.likely_donations.order("date asc")
      end

    end
  end
end
