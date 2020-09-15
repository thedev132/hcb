module PlaidTransactionService
  module Likely
    class FeePayment
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%bank fee%'")
      end
    end
  end
end
