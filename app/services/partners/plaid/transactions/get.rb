module Partners
  module Plaid
    module Transactions
      class Get
        DATE_FORMAT = "%Y-%m-%d"
        COUNT = 500

        include ::Partners::Plaid::Shared::Client

        def initialize(bank_account_id:, start_date: (Time.now.utc - 15.days).strftime(DATE_FORMAT))
          @bank_account_id = bank_account_id

          @start_date = start_date
        end

        def run
          plaid_transactions
        end

        private

        def plaid_transactions
          resp = fetch_transactions
          ts = resp["transactions"]

          while ts.length < resp["total_transactions"]
            resp = fetch_transactions(offset: ts.length)
            ts += resp["transactions"]
          end

          ts
        end

        def fetch_transactions(offset: 0)
          begin
            results = plaid_client.transactions.get(access_token,
                                                    start_date,
                                                    end_date,
                                                    offset: offset,
                                                    count: COUNT,
                                                    account_ids: account_ids)

            Rails.logger.info "plaid_client.transaction.get start_date=#{start_date} end_date=#{end_date} offset=#{offset} count=#{COUNT} account_ids=#{account_ids} total_transactions=#{results["total_transactions"]}"

            # mark_plaid_item_success! # TODO

            results
          rescue ::Plaid::ItemError, ::Plaid::InvalidInputError => error
            Airbrake.notify("plaid_client.transactions.get failed for bank_account #{bank_account.id} with access token #{access_token}. #{error.message}")

            # mark_plaid_item_failed! # TODO

            { "accounts" => [], "transactions" => [], "total_transactions" => 0 }
          end
        end

        def access_token
          @access_token ||= bank_account.plaid_access_token
        end

        def start_date
          @start_date
        end

        def end_date
          (Time.now.utc + 2.days).strftime(DATE_FORMAT)
        end

        def mark_plaid_item_failed!
          bank_account.touch(:failed_at) # mark plaid item failed
          BankAccount.increment_counter(:failure_count, bank_account.id)
        end

        def mark_plaid_item_success!
          bank_account.update_attribute(:failed_at, nil)
        end

        def account_ids
          [bank_account.plaid_account_id]
        end

        def bank_account
          @bank_account ||= BankAccount.find(@bank_account_id)
        end
      end
    end
  end
end

