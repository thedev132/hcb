# frozen_string_literal: true

module TransactionEngine
  module RawPlaidTransactionService
    module Plaid
      class Import
        include ::TransactionEngine::Shared

        def initialize(bank_account_id:, start_date: nil, end_date: Date.today)
          @bank_account_id = bank_account_id
          @start_date = fmt_date((start_date || last_1_month))
          @end_date = fmt_date end_date
        end

        def run
          plaid_transactions.each do |plaid_transaction|
            next unless plaid_transaction["pending"] == false

            ::RawPlaidTransaction.find_or_initialize_by(plaid_transaction_id: plaid_transaction["transaction_id"]).tap do |pt|
              pt.plaid_account_id = plaid_transaction["account_id"]
              pt.plaid_item_id = plaid_transaction["item_id"]

              pt.plaid_transaction = plaid_transaction

              pt.amount = -plaid_transaction["amount"] # IMPORTANT: deprecated transaction engine used negatives so new must also (for Plaid only)
              pt.date_posted = plaid_transaction["date"]
              pt.pending = plaid_transaction["pending"]

              pt.unique_bank_identifier = unique_bank_identifier
            end.save!
          end
        end

        private

        def plaid_transactions
          @plaid_transactions ||= ::Partners::Plaid::Transactions::Get.new(
                                            bank_account_id: @bank_account_id,
                                            start_date:      @start_date,
                                            end_date:        @end_date
                                          ).run
        end

        def fmt_date(date)
          unless date.methods.include? :strftime
            raise ArgumentError.new("Only dates are allowed")
          end
          date.strftime(::Partners::Plaid::Transactions::Get::DATE_FORMAT)
        end
      end
    end
  end
end
