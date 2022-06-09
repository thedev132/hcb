# frozen_string_literal: true

module PendingEventMappingEngine
  module Decline
    class IncomingDisbursement
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          Single::IncomingDisbursement.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.incoming_disbursement
      end

    end
  end
end
