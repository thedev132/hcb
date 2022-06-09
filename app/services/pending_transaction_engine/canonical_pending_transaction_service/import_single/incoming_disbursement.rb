# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class IncomingDisbursement
        def initialize(raw_pending_incoming_disbursement_transaction:)
          @rpidt = raw_pending_incoming_disbursement_transaction
        end

        def run
          return existing_canonical_pending_transaction if existing_canonical_pending_transaction

          ::CanonicalPendingTransaction.find_or_create_by(attrs)
        end

        private

        def attrs
          {
            date: @rpidt.date,
            memo: @rpidt.memo,
            amount_cents: @rpidt.amount_cents,
            raw_pending_incoming_disbursement_transaction: @rpidt
          }
        end

        def existing_canonical_pending_transaction
          @existing_canonical_pending_transaction ||= ::CanonicalPendingTransaction.find_by(raw_pending_incoming_disbursement_transaction_id: @rpidt.id)
        end

      end
    end
  end
end
