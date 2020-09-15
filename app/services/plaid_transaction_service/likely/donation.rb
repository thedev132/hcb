module PlaidTransactionService
  module Likely
    class Donation
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%hackc donate%' or plaid_transaction->>'name' ilike '%hack club event%'")
      end
    end
  end
end
