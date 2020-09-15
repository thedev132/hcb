module RawPlaidTransactionService
  module Plaid
    class Import
      def initialize(bank_account_id:)
        @bank_account_id = bank_account_id
      end

      def run
        plaid_transactions.each do |plaid_transaction|
          next unless plaid_transaction['pending'] == false

          ::RawPlaidTransaction.find_or_initialize_by(plaid_transaction_id: plaid_transaction['transaction_id']).tap do |pt|
            pt.plaid_account_id = plaid_transaction['account_id']
            pt.plaid_item_id = plaid_transaction['item_id']

            pt.plaid_transaction = plaid_transaction

            pt.amount = plaid_transaction['amount']
            pt.date_posted = plaid_transaction['date']
            pt.pending = plaid_transaction['pending']
          end.save!
        end
      end

      private

      def plaid_transactions
        @plaid_transactions ||= ::Partners::Plaid::Transactions::Get.new(bank_account_id: @bank_account_id, start_date: start_date).run
      end

      def start_date
        (Time.now.utc - 5.years).strftime(::Partners::Plaid::Transactions::Get::DATE_FORMAT)
      end
    end
  end
end
