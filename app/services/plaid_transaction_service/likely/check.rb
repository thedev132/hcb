module PlaidTransactionService
  module Likely
    class Check
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%dda#%' or plaid_transaction->>'name' ilike '%check%'")
      end
    end
  end
end
