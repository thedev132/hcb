# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Invoice
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%hackc payout%' or plaid_transaction->>'name' ilike '%hack club event%'")
        end
      end
    end
  end
end
