module TransactionEngine
  module FixMistakes
    class Plaid
      def initialize(bank_account_id:, start_date:, end_date:)
        @bank_account_id = bank_account_id

        @start_date = start_date || (Date.today - 5.years).strftime(::Partners::Plaid::Transactions::Get::DATE_FORMAT)
        @end_date = end_date || (Date.today + 2.days).strftime(::Partners::Plaid::Transactions::Get::DATE_FORMAT)
      end

      def run
        raise ArgumentError, "BankAccount #{@bank_account_id} not found" unless bank_account

        # 1. identify the plaid transaction ids that plaid deleted from their api/infra
        plaid_transaction_ids_that_were_deleted_remotely_by_plaid = local_plaid_transaction_ids - remote_plaid_transaction_ids

        # 2. iterate over
        RawPlaidTransaction.where(plaid_transaction_id: plaid_transaction_ids_that_were_deleted_remotely_by_plaid).find_each(batch_size: 100) do |rpt|
          # 3. remove from our system
          ::RawPlaidTransactionService::Delete.new(raw_plaid_transaction_id: rpt.id).run
        end

        Airbrake.notify("Plaid Mistakes: #{plaid_transaction_ids_that_were_deleted_remotely_by_plaid}")

        plaid_transaction_ids_that_were_deleted_remotely_by_plaid
      end

      private

      def local_plaid_transaction_ids
        @local_plaid_transaction_ids ||= RawPlaidTransaction.where("plaid_account_id = ? and plaid_transaction->>'date' >= ? and plaid_transaction->>'date' <= ?", plaid_account_id, @start_date, @end_date).pluck(:plaid_transaction_id)
      end

      def plaid_account_id
        @plaid_account_id ||= bank_account.plaid_account_id
      end

      def bank_account
        @bank_account ||= ::BankAccount.find(@bank_account_id)
      end

      def remote_plaid_transaction_ids
        @remote_plaid_transaction_ids ||= ::Partners::Plaid::Transactions::Get.new(transaction_ids_attrs).run.map(&:transaction_id)
      end

      def transaction_ids_attrs
        {
          bank_account_id: @bank_account_id,
          start_date: @start_date,
          end_date: @end_date
        }
      end
    end
  end
end
