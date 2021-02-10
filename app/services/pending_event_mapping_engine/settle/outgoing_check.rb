module PendingEventMappingEngine
  module Settle
    class OutgoingCheck
      def run
        unsettled.find_each do |cpt|
          # 1. identify check number
          check_number = cpt.raw_pending_outgoing_check_transaction.check_number
          check = Check.where(check_number: check_number).first
          Airbrake.notify("Check for check_number #{check_number} not found") unless check
          next unless check
          event = check.event

          # 2. look up canonical - scoped to event for added accuracy
          cts = event.canonical_transactions.where("memo ilike '#{check_number} CHECK%'")

          next if cts.count < 1 # no match found yet. not processed.
          Airbrake.notify("matched more than 1 canonical transaction for check_number #{check_number}") if cts.count > 1
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
        CanonicalPendingTransaction.unsettled.outgoing_check
      end
    end
  end
end
