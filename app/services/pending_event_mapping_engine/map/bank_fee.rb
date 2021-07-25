# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class BankFee
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          next unless cpt.raw_pending_bank_fee_transaction.likely_event_id

          attrs = {
            event_id: cpt.raw_pending_bank_fee_transaction.likely_event_id,
            canonical_pending_transaction_id: cpt.id
          }
          CanonicalPendingEventMapping.create!(attrs)
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.bank_fee
      end
    end
  end
end
