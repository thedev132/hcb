module TransactionEngine
  class Nightly
    def initialize
    end

    def run
      # 1 raw imports
      import_raw_plaid_transactions!
      import_other_raw_plaid_transactions!
      import_raw_emburse_transactions!
      import_raw_stripe_transactions!

      # 2 hashed 
      hash_raw_plaid_transactions!
      hash_raw_emburse_transactions!
      hash_raw_stripe_transactions!
      hash_raw_csv_transactions!

      # 3 canonical
      canonize_hashed_transactions!
    end

    private

    def import_raw_plaid_transactions!
      BankAccount.syncing.pluck(:id).each do |bank_account_id|
        puts "raw_plaid_transactions: #{bank_account_id}"

        ::TransactionEngine::RawPlaidTransactionService::Plaid::Import.new(bank_account_id: bank_account_id, start_date: start_date).run
      end
    end

    def import_other_raw_plaid_transactions!
      ::TransactionEngine::RawPlaidTransactionService::BankAccount1::Import.new.run
      ::TransactionEngine::RawPlaidTransactionService::BankAccount9::Import.new.run
    end

    def import_raw_emburse_transactions!
      # Check for TXs in 1 month blocks over the past 5 years at increments of 15 days
      120.times do |n|
        from = Date.today - (n * 15).days
        to = from + 15.days

        puts "raw_emburse_transactions: #{from} - #{to}"

        begin
          ::TransactionEngine::RawEmburseTransactionService::Emburse::Import.new(start_date: from, end_date: to).run
        rescue => e
          puts e
        end
      end
    end

    def import_raw_stripe_transactions!
      ::TransactionEngine::RawStripeTransactionService::Stripe::Import.new.run
    end

    def hash_raw_plaid_transactions!
      ::TransactionEngine::HashedTransactionService::RawPlaidTransaction::Import.new.run
    end

    def hash_raw_emburse_transactions!
      ::TransactionEngine::HashedTransactionService::RawEmburseTransaction::Import.new.run
    end

    def hash_raw_stripe_transactions!
      # IMPLEMENT
    end

    def hash_raw_csv_transactions!
      ::TransactionEngine::HashedTransactionService::RawCsvTransaction::Import.new.run
    end

    def canonize_hashed_transactions!
      ::TransactionEngine::CanonicalTransactionService::Import::All.new.run
    end

    def start_date
      Time.now.utc - 5.years
    end
  end
end
