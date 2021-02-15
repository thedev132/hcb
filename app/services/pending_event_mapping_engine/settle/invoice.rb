module PendingEventMappingEngine
  module Settle
    class Invoice
      def run
        unsettled.find_each do |cpt|
          # 1. identify invoice
          invoice = cpt.raw_pending_invoice_transaction.invoice
          Airbrake.notify("invoice not found for canonical pending transaction #{cpt.id}") unless invoice
          next unless invoice

          next unless invoice.payout
          event = invoice.event

          prefix = grab_prefix(invoice: invoice)

          # 2. look up canonical - scoped to event for added accuracy
          cts = event.canonical_transactions.where("memo ilike '%PAYOUT% #{prefix}%'")

          # 2.b special case if invoice is quite old & now results
          #cts = event.canonical_transactions.where("memo ilike '%DONAT% #{prefix[0]}%'") if cts.count < 1 && invoice.created_at < Time.utc(2020, 1, 1) # shorter prefix. see  id 1 for example.

          next if cts.count < 1 # no match found yet. not processed.
          Airbrake.notify("matched more than 1 canonical transaction for canonical pending transaction #{cpt.id}") if cts.count > 1
          ct = cts.first

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

      def grab_prefix(invoice:)
        statement_descriptor = invoice.payout.statement_descriptor

        # tx name can be one of two forms, from observation:
        # 1. HACKC PAYOUT [PREFIX] ST-XXXXXXXXXX The Hack Foundation
        #   -- if it's a complete TX
        # 2. HACKC PAYOUT [PREFIX]
        #   -- if it's a pending TX
        # where PREFIX appears in InvoicePayout.statement_descriptor as
        #   "PAYOUT [PREFIX]"
        #
        # We should parse out the PREFIX from the TX.name, try to find any matching
        # InvoicePayouts, and match it.

        cleanse = statement_descriptor.upcase.gsub("HACK CLUB BANK PAYOUT", "")
        cleanse = cleanse.gsub("HACKC PAYOUT", "")
        cleanse.split(" ")[0][0..2].upcase
      end

    end
  end
end
