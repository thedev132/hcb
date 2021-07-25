# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class ImportSingle
        def initialize(remote_stripe_transaction:)
          @remote_stripe_transaction = remote_stripe_transaction
        end

        def run
          rpst = ::RawPendingStripeTransaction.find_or_initialize_by(stripe_transaction_id: t[:id])

          rpst.stripe_transaction = t
          rpst.amount_cents = -t[:amount] # it's a transaction card swipe so it is always negative (but Stripe returns it as a positive value)
          rpst.date_posted = Time.at(t[:created])

          rpst.save!

          rpst
        end

        private

        def t
          @t ||= @remote_stripe_transaction
        end
      end
    end
  end
end
