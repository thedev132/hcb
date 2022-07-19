# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingInvoiceTransactionService
    module Invoice
      class Import
        def initialize
        end

        def run
          pending_invoice_transactions.each do |pit|
            ::PendingTransactionEngine::RawPendingInvoiceTransactionService::Invoice::ImportSingle.new(invoice: pit).run
          end

          nil
        end

        private

        def pending_invoice_transactions
          @pending_invoice_transactions ||= ::Invoice.paid_v2.not_manually_marked_as_paid.where("amount_due > 0")
        end

      end
    end
  end
end
