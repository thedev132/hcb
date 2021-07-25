# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Likely
      class Ach
        def run
          ::RawPlaidTransaction.where("plaid_transaction->>'name' ilike '%busbillpay%'")
        end
      end
    end
  end
end
