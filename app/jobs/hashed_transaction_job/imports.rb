# frozen_string_literal: true

module HashedTransactionJob
  class Imports < ApplicationJob
    def perform
      ::HashedTransactionService::PlaidTransaction::Import.new.run
    end
  end
end
