# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class IncomingDisbursement
        def run
          raw_pending_incoming_disbursement_transactions.find_each(batch_size: 100) do |rpidt|
            ImportSingle::IncomingDisbursement.new(raw_pending_incoming_disbursement_transaction: rpidt).run
          end
        end

        private

        def raw_pending_incoming_disbursement_transactions
          RawPendingIncomingDisbursementTransaction.where.missing :canonical_pending_transaction
        end

      end
    end
  end
end
