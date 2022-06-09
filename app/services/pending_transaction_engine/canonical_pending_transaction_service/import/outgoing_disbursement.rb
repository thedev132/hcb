# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class OutgoingDisbursement
        def run
          raw_pending_outgoing_disbursement_transactions.find_each(batch_size: 100) do |rpodt|
            ActiveRecord::Base.transaction do
              ImportSingle::OutgoingDisbursement(raw_pending_outgoing_disbursement_transaction: rpodt)
            end
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
