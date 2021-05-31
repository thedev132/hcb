module EventMappingEngine
  module Map
    class BankFees
      def run
        likely_bank_fees.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::BankFee.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_bank_fees
        ::CanonicalTransaction.unmapped.likely_hack_club_fee.order("date asc")
      end

    end
  end
end
