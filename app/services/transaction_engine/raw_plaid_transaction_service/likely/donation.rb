module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Donation
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%hackc donate%' or plaid_transaction->>'name' ilike '%hack club event%'")
        end
      end
    end
  end
end
