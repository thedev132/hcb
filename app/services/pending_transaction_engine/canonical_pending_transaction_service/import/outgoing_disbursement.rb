# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class OutgoingDisbursement
        def run
          raw_pending_outgoing_disbursement_transactions.find_each(batch_size: 100) do |rpodt|
            ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingDisbursement.new(raw_pending_outgoing_disbursement_transaction: rpodt).run
          end
        end

        private

        def raw_pending_outgoing_disbursement_transactions
          RawPendingOutgoingDisbursementTransaction.where.missing :canonical_pending_transaction
        end

      end
    end
  end
end
