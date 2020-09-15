module PlaidTransactionService
  module Likely
    class Ach
      def run
        ::PlaidTransaction.where("plaid_transaction->>'name' ilike '%busbillpay%'")
      end
    end
  end
end
