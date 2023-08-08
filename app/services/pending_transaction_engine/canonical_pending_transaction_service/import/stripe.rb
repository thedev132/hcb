# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class Stripe
        def run
          raw_pending_stripe_transactions_ready_for_processing.find_each(batch_size: 100) do |rpst|

            ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Stripe.new(raw_pending_stripe_transaction: rpst).run

          end
        end

        private

        def raw_pending_stripe_transactions_ready_for_processing
          RawPendingStripeTransaction
            .left_joins(:canonical_pending_transaction)
            .where("canonical_pending_transactions.id IS NULL OR canonical_pending_transactions.amount_cents != raw_pending_stripe_transactions.amount_cents")
        end

      end
    end
  end
end
