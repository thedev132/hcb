# frozen_string_literal: true

module TransactionEngine
  module RawIncreaseTransactionService
    module Increase
      class Import
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
            end
          end

          true
        end

        private

        def increase_transactions
          conn = Faraday.new(
            url: increase_url,
            headers: { "Authorization" => "Bearer #{increase_api_key}" }
          ) do |f|
            f.response :json
          end

          transactions = []

          cursor = nil

          loop do
            response = conn.get "/transactions", { limit: 100, cursor: cursor, "created_at.on_or_after" => @start_date.iso8601 }

            transactions += response.body["data"]

            if response.body["next_cursor"]
              cursor = response.body["next_cursor"]
            else
              break
            end
          end

          transactions
        end

        def increase_url
          if Rails.env.production?
            "https://api.increase.com"
          else
            "https://sandbox.increase.com"
          end
        end

        def increase_api_key
          if Rails.env.production?
            Rails.application.credentials.increase.production_key
          else
            Rails.application.credentials.increase.sandbox_key
          end
        end

      end
    end
  end
end
