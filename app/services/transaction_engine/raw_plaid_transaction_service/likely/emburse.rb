# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Emburse
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%emburse%' or plaid_transaction->>'merchant' ilike '%emburse%'")
        end
      end
    end
  end
end
