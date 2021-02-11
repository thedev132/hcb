module PendingEventMappingEngine
  module Decline
    class OutgoingCheck
      def run
        unsettled.find_each do |cpt|
          check = cpt.raw_pending_outgoing_check_transaction.check
          next unless check

          # 1. identify canceled/rejected check
          if check.canceled? || check.rejected?
            # 2. mark this as decliend
            attrs = {
              canonical_pending_transaction_id: cpt.id
            }
            CanonicalPendingDeclinedMapping.create!(attrs)
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.outgoing_check
      end
    end
  end
end
