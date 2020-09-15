module PlaidTransactionService
  module Likely
    class Invoice
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%hackc payout%' or plaid_transaction->>'name' ilike '%hack club event%'")
      end
    end
  end
end
