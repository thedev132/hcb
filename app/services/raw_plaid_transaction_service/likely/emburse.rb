module RawPlaidTransactionService
  module Likely
    class Emburse
      def run
        ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%emburse%' or plaid_transaction->>'merchant' ilike '%emburse%'")
      end
    end
  end
end
