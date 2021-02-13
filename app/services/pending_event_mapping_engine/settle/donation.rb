module PendingEventMappingEngine
  module Settle
    class Donation
      def run
        unsettled.find_each do |cpt|
          # 1. identify donation
          donation = cpt.raw_pending_donation_transaction.donation
          Airbrake.notify("Donation not found for canonical pending transaction #{cpt.id}") unless donation
          next unless donation

          next unless donation.payout
          prefix = donation.payout.statement_descriptor.gsub("DONATE", "").strip[0..2].upcase
          event = donation.event

          # 2. look up canonical - scoped to event for added accuracy
          cts = event.canonical_transactions.where("memo ilike '%DONATE #{prefix}%'")

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
        CanonicalPendingTransaction.unsettled.donation
      end
    end
  end
end
