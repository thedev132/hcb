module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class Import
        def initialize
        end

        def run
          pending_stripe_transactions.each do |t|
            ::RawPendingStripeTransaction.find_or_initialize_by(stripe_transaction_id: t[:id]).tap do |st|
              st.stripe_transaction = t
              st.amount_cents = -t[:amount] # it's a transaction card swipe so it is always negative (but Stripe returns it as a positive value)
              st.date_posted = Time.at(t[:created])
            end.save!
          end

          nil
        end

        private

        def pending_stripe_transactions
          @pending_stripe_transactions ||= ::Partners::Stripe::Issuing::Authorizations::List.new.run
        end
      end
    end
  end
end
