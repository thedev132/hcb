module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class FeePayment
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%bank fee%'")
        end
      end
    end
  end
end
