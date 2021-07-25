# frozen_string_literal: true

module PendingEventMappingEngine
  module Settle
    class InvoiceHcbCode
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 1. Wait for 2 canonical transactions (payout and fee reimbursement)
          if cpt.local_hcb_code.canonical_transactions.length == 2
            # 2. identify ct
            ct = cpt.local_hcb_code.canonical_transactions.first

            # 3. mark no longer pending
            attrs = {
              canonical_transaction_id: ct.id,
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingSettledMapping.create!(attrs)
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.invoice
      end
    end
  end
end
