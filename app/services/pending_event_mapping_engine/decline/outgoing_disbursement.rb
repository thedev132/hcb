# frozen_string_literal: true

module PendingEventMappingEngine
  module Decline
    class OutgoingDisbursement
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          Single::OutgoingDisbursement(canonical_pending_transaction: cpt)
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.outgoing_disbursement
      end

    end
  end
end
