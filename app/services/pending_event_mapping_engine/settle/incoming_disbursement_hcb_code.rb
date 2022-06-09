# frozen_string_literal: true

module PendingEventMappingEngine
  module Settle
    class IncomingDisbursementHcbCode
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 1. identify disbursement
          disbursement = cpt.disbursement
          Airbrake.notify("Disbursement not found for canonical pending transaction #{cpt.id}") unless disbursement
          next unless disbursement

          # 2. look up canonical transactions by hcb & amount
          cts = disbursement.local_hcb_code.canonical_transactions.where(amount_cents: cpt.amount_cents)
          ct = cts.first

          next unless ct

          if cts.size > 1
            Airbrake.notify("Multiple settled transactions for canonical pending transaction #{cpt.id}")
          end

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
        CanonicalPendingTransaction.unsettled.incoming_disbursement
      end

    end
  end
end
