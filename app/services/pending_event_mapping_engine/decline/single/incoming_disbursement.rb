# frozen_string_literal: true

module PendingEventMappingEngine
  module Decline
    module Single
      class IncomingDisbursement
        def initialize(canonical_pending_transaction:)
          @canonical_pending_transaction = canonical_pending_transaction
        end

        def run
          return unless disbursement

          return unless disbursement.errored? || disbursement.rejected?

          CanonicalPendingDeclinedMapping.create!(
            canonical_pending_transaction_id: @canonical_pending_transaction.id
          )
        end

        private

        def disbursement
          @canonical_pending_transaction.local_hcb_code.disbursement
        end

      end
    end
  end
end
