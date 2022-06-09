# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class OutgoingDisbursement
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          Single::OutgoingDisbursement.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.outgoing_disbursement
      end

    end
  end
end
