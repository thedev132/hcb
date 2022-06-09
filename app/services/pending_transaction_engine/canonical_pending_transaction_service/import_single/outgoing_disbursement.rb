# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class OutgoingDisbursement
        def initialize(raw_pending_outgoing_disbursement_transaction:)
          @rpodt = raw_pending_outgoing_disbursement_transaction
        end

        def run
          return existing_canonical_pending_transaction if existing_canonical_pending_transaction

          ::CanonicalPendingTransaction.find_or_create_by(attrs)
        end

        private

        def attrs
          {
            date: @rpodt.date,
            memo: @rpodt.memo,
            amount_cents: @rpodt.amount_cents,
            raw_pending_outgoing_disbursement_transaction: @rpodt
          }
        end

        def existing_canonical_pending_transaction
          @existing_canonical_pending_transaction ||= ::CanonicalPendingTransaction.find_by(raw_pending_outgoing_disbursement_transaction_id: @rpodt.id)
        end


      end
    end
  end
end
