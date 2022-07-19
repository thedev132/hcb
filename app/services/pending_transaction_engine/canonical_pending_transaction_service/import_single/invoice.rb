# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class Invoice
        def initialize(raw_pending_invoice_transaction:)
          @raw_pending_invoice_transaction = raw_pending_invoice_transaction
        end

        def run
          return existing_canonical_pending_transaction if existing_canonical_pending_transaction

          attrs = {
            date: @raw_pending_invoice_transaction.date,
            memo: @raw_pending_invoice_transaction.memo,
            amount_cents: @raw_pending_invoice_transaction.amount_cents,
            raw_pending_invoice_transaction_id: @raw_pending_invoice_transaction.id,
            fronted: true
          }
          ::CanonicalPendingTransaction.create!(attrs)
        end

        private

        def existing_canonical_pending_transaction
          @existing_canonical_pending_transaction ||= ::CanonicalPendingTransaction.where(raw_pending_invoice_transaction_id: @raw_pending_invoice_transaction.id).first
        end

      end
    end
  end
end
