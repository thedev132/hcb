module EventMappingEngine
  module Map
    class FeeReimbursements
      def run
        likely_fee_reimbursements.find_each(batch_size: 100) do |ct|
          guessed_event_id = ::EventMappingEngine::GuessEventId::FeeReimbursement.new(canonical_transaction: ct).run

          next unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_fee_reimbursements
        ::CanonicalTransaction.unmapped.likely_fee_reimbursements.where("date >= '2021-01-01'").order("date asc")
      end

    end
  end
end
