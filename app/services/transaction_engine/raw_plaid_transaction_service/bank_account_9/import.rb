module TransactionEngine
  module RawPlaidTransactionService
    module BankAccount9
      class Import
        include ::TransactionEngine::Shared

        BANK_ACCOUNT_ID = 9

        def initialize(start_date: nil)
          @start_date = start_date || last_1_month

          @bank_account_id = BANK_ACCOUNT_ID
        end

        def run
          deprecated_transactions.each do |transaction|
            ::RawPlaidTransaction.find_or_initialize_by(plaid_transaction_id: transaction.plaid_id).tap do |pt|
              pt.plaid_account_id = plaid_account_id
              pt.plaid_item_id = nil
              pt.plaid_transaction = {
                name: transaction.name
              }
              pt.amount_cents = transaction.amount
              pt.date_posted = transaction.date
              pt.pending = transaction.pending

              pt.unique_bank_identifier = unique_bank_identifier
            end.save!
          end
        end

        private

        def deprecated_transactions
          @deprecated_transactions ||= bank_account.transactions.where('pending is false and plaid_id is not null and amount != 0 and date >= ?', @start_date)
        end

        def bank_account
          @bank_account ||= BankAccount.find(BANK_ACCOUNT_ID)
        end

        def plaid_account_id
          @plaid_account_id ||= bank_account.plaid_account_id
        end
      end
    end
  end
end
