module RawPlaidTransactionService
  module Likely
    class Expensify
      def run
        ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%expensify%'")
      end
    end
  end
end
