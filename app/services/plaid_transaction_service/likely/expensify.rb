module PlaidTransactionService
  module Likely
    class Expensify
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%expensify%'")
      end
    end
  end
end
