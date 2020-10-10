module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class FeeReimbursement
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%fee refund%'")
        end
      end
    end
  end
end
