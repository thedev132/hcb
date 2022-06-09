# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class IncomingDisbursement
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          Single::IncomingDisbursement.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.incoming_disbursement
      end

    end
  end
end
