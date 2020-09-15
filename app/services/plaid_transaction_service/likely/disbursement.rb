module PlaidTransactionService
  module Likely
    class Disbursement
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%hcb disburse%'")
      end
    end
  end
end
