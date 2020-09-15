module PlaidTransactionService
  module Likely
    class FeeReimbursement
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%fee refund%'")
      end
    end
  end
end
