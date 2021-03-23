module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class Stripe
        def initialize(raw_pending_stripe_transaction:)
          @raw_pending_stripe_transaction = raw_pending_stripe_transaction
        end

        def run
          return existing_canonical_pending_transaction if existing_canonical_pending_transaction

          ActiveRecord::Base.transaction do
            attrs = {
              date: @raw_pending_stripe_transaction_id.date,
              memo: @raw_pending_stripe_transaction_id.memo,
              amount_cents: @raw_pending_stripe_transaction_id.amount_cents,
              raw_pending_stripe_transaction_id: @raw_pending_stripe_transaction_id.id
            }
            ::CanonicalPendingTransaction.create!(attrs)
          end
        end

        private

        def existing_canonical_pending_transaction
          @existing_canonical_pending_transaction ||= ::CanonicalPendingTransaction.where(raw_pending_stripe_transaction_id: @raw_pending_stripe_transaction_id.id).first
        end
      end
    end
  end
end
