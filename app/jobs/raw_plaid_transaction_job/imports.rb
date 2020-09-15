# frozen_string_literal: true

module RawPlaidTransactionJob
  class Imports < ApplicationJob
    def perform
      BankAccount.syncing.pluck(:id).each do |bank_account_id|
        ::RawPlaidTransactionService::Plaid::Import.new(bank_account_id: bank_account_id).run
      end
    end
  end
end
