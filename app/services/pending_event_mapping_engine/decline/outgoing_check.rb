module PendingEventMappingEngine
  module Decline
    class OutgoingCheck
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          check = cpt.raw_pending_outgoing_check_transaction.check
          next unless check

          # 1. identify canceled/rejected check
          if check.canceled? || check.rejected? || check.refunded?
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
        CanonicalPendingTransaction.unsettled.outgoing_check
      end
    end
  end
end
