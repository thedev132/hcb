# frozen_string_literal: true

module PendingEventMappingEngine
  module Settle
    class Stripe
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          stripe_authorization_id = cpt.raw_pending_stripe_transaction.stripe_transaction_id

          raw_stripe_transactions = RawStripeTransaction.where(stripe_authorization_id:)

          raw_stripe_transactions.each do |rst|
            # 1. lookup canonical
            rst.hashed_transactions.each do |ht|
              ct = ht.canonical_transaction

              next unless ct

              # 2. mark no longer pending
              CanonicalPendingTransactionService::Settle.new(
                canonical_transaction: ct,
                canonical_pending_transaction: cpt
              ).run!
            end
          end
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.stripe
      end

    end
  end
end
