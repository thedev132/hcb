module PendingEventMappingEngine
  module Decline
    class OutgoingAch
      def run
        unsettled.find_each do |cpt|
          ach_transfer = cpt.raw_pending_outgoing_ach_transaction.ach_transfer
          next unless ach_transfer

          # 1. identify rejected ach_transfers
          if ach_transfer.rejected?
            # 2. mark this as declined
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.outgoing_ach
      end
    end
  end
end
