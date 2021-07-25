# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Github
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%github grant%'")
        end
      end
    end
  end
end
