module TransactionEngine
  class Nightly
    def initialize
    end

    def run
      # 1 raw imports
      import_raw_plaid_transactions!
      import_raw_emburse_transactions!
      import_raw_stripe_transactions!

      # 2 hashed 
      ::TransactionEngine::HashedTransactionService::RawPlaidTransaction::Import.new.run
      ::TransactionEngine::HashedTransactionService::RawEmburseTransaction::Import.new.run

      # 3 canonical
      ::TransactionEngine::CanonicalTransactionService::Import.new.run
    end

    private

    def import_raw_plaid_transactions!
      BankAccount.syncing.pluck(:id).each do |bank_account_id|
        puts "raw_plaid_transactions: #{bank_account_id}"

        ::TransactionEngine::RawPlaidTransactionService::Plaid::Import.new(bank_account_id: bank_account_id).run
      end
    end

    def import_raw_emburse_transactions!
      200.times do |n|
        from = (n * 10).days.ago

        puts "raw_emburse_transactions: #{from}"

        ::TransactionEngine::RawEmburseTransactionService::Emburse::Import.new(from: from).run
      end
    end

    def import_raw_stripe_transactions!
      # IMPLEMENT
    end
  end
end
