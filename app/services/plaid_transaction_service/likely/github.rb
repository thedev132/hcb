module PlaidTransactionService
  module Likely
    class Github
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%github grant%'")
      end
    end
  end
end
