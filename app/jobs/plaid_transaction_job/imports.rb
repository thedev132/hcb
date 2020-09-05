# frozen_string_literal: true

module PlaidTransactionJob
  class Imports < ApplicationJob
    def perform
      BankAccount.syncing.pluck(:id).each do |bank_account_id|
        ::PlaidTransactionService::Plaid::Import.new(bank_account_id: bank_account_id).run
      end
    end
  end
end
