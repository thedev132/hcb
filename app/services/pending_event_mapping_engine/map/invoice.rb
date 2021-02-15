module PendingEventMappingEngine
  module Map
    class Invoice
      def run
        unmapped.find_each do |cpt|
          next unless cpt.raw_pending_invoice_transaction.likely_event_id

          attrs = {
            event_id: cpt.raw_pending_invoice_transaction.likely_event_id,
            canonical_pending_transaction_id: cpt.id
          }
          CanonicalPendingEventMapping.create!(attrs)
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.invoice
      end
    end
  end
end
