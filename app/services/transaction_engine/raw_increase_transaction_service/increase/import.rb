# frozen_string_literal: true

module TransactionEngine
  module RawIncreaseTransactionService
    module Increase
      class Import
        include IncreaseService::AccountIds

        def initialize(start_date: 1.month.ago)
          @start_date = start_date
        end

        def run
          increase_transactions.each do |transaction|
            RawIncreaseTransaction.find_or_create_by(increase_transaction_id: transaction["id"]) do |rit|
              rit.amount_cents = transaction["amount"]
              rit.date_posted = transaction["created_at"]
              rit.increase_account_id = transaction["account_id"]
              rit.increase_route_type = transaction["route_type"]
              rit.increase_route_id = transaction["route_id"]
              rit.description = transaction["description"]
              rit.increase_transaction = transaction
            end
          end

          true
        end

        private

        def increase_transactions
          increase = IncreaseService.new

          transactions = []
          cursor = nil

          loop do
            response = increase.get "/transactions",
                                    account_id: fs_main_account_id,
                                    limit: 100,
                                    cursor: cursor,
                                    "created_at.on_or_after" => @start_date.iso8601

            transactions += response["data"]

            if response["next_cursor"]
              cursor = response["next_cursor"]
            else
              break
            end
          end

          transactions
        end

      end
    end
  end
end
