module PendingEventMappingEngine
  module Settle
    class OutgoingAch
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          # 1. identify ach number
          ach_transfer = cpt.ach_transfer
          Airbrake.notify("AchTransfer not found for canonical pending transaction #{cpt.id}") unless ach_transfer
          next unless ach_transfer
          event = ach_transfer.event

          # 2. look up canonical - scoped to event for added accuracy
          cts = event.canonical_transactions.where("memo ilike '%#{::TransactionEngine::SyntaxSugarService::Shared::OUTGOING_ACH_MEMO_PART}%' and amount_cents = #{cpt.amount_cents} and date >= ?", cpt.date).order("date asc")

          next if cts.count < 1 # no match found yet. not processed.
          Airbrake.notify("matched more than 1 canonical transaction for ach transfer #{ach_transfer.id}") if cts.count > 1
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
        CanonicalPendingTransaction.unsettled.outgoing_ach
      end
    end
  end
end
