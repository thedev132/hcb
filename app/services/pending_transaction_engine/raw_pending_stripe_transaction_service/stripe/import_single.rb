module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class ImportSingle
        def initialize(remote_stripe_transaction:)
          @remote_stripe_transaction = remote_stripe_transaction
        end

        def run
          ::RawPendingStripeTransaction.find_or_initialize_by(stripe_transaction_id: t[:id]).tap do |st|
            st.stripe_transaction = t
            st.amount_cents = -t[:amount] # it's a transaction card swipe so it is always negative (but Stripe returns it as a positive value)
            st.date_posted = Time.at(t[:created])
          end.save!
        end

        private

        def t
          @t ||= @remote_stripe_transaction
        end
      end
    end
  end
end
