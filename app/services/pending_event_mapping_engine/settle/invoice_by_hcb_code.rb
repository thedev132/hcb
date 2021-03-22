module PendingEventMappingEngine
  module Settle
    class InvoiceByHcbCode
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 1. identify invoice
          invoice = cpt.invoice
          Airbrake.notify("invoice not found for canonical pending transaction #{cpt.id}") unless invoice
          next unless invoice
          event = invoice.event
          hcb_code = invoice.hcb_code

          # 2. identify canonical transaction
          ct = event.canonical_transactions.where(hcb_code: hcb_code).first
          next unless ct

          # 3. mark no longer pending
          attrs = {
            canonical_transaction_id: ct.id,
            canonical_pending_transaction_id: cpt.id
          }
          CanonicalPendingSettledMapping.create!(attrs)
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.invoice
      end
    end
  end
end
