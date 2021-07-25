# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Expensify
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%expensify%'")
        end
      end
    end
  end
end
