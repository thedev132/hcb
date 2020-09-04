module Partners
  module Plaid
    module Transactions
      class Get
        include ::Partners::Plaid::Shared::Client

				def initialize(bank_account_id:)
					@bank_account_id = bank_account_id
				end

        def run
          plaid_transactions
        end

        private

        def plaid_transactions
          @plaid_transactions ||= fetch_transactions['transactions']
        end

        def fetch_transactions
          begin
            results = plaid_client.transactions.get(access_token, start_date, end_date, account_ids: account_ids)

            # mark_plaid_item_success! # TODO

            results
          rescue ::Plaid::ItemError, ::Plaid::InvalidInputError => error
            Airbrake.notify("plaid_client.transactions.get failed for bank_account #{bank_account.id} with access token #{access_token}. #{error.message}")

            # mark_plaid_item_failed! # TODO

            { 'accounts' => [], 'transactions' => [] }
          end
        end

        def access_token
          @access_token ||= bank_account.plaid_access_token
        end

        def start_date
          (Time.now.utc - 15.days).strftime(strftime_format)
        end

        def end_date
          (Time.now.utc + 2.days).strftime(strftime_format)
        end

        def strftime_format
          '%Y-%m-%d'
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

