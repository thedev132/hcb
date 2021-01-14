module TransactionEngine
  module RawStripeTransactionService
    module Stripe
      class Import
        include ::TransactionEngine::Shared

        def initialize(start_date: nil)
          @start_date = start_date || last_1_month

          @bank_account_id = "STRIPEISSUING1"
        end

        def run
          stripe_transactions.each do |t|
            ::RawStripeTransaction.find_or_initialize_by(stripe_transaction_id: t[:id]).tap do |st|
              st.stripe_transaction = t
              st.amount_cents = t[:amount]
              st.date_posted = Time.at(t[:created])
              st.stripe_authorization_id = t[:authorization]

              st.unique_bank_identifier = unique_bank_identifier
            end.save!
          end

          nil
        end

        private

        def stripe_transactions
          @stripe_transactions ||= ::Partners::Stripe::Issuing::Transactions::List.new(start_date: @start_date).run
        end
      end
    end
  end
end
