module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class Stripe
        def run
          raw_pending_stripe_transactions_ready_for_processing.find_each(batch_size: 100) do |rpst|

            ActiveRecord::Base.transaction do
              attrs = {
                date: rpst.date,
                memo: rpst.memo,
                amount_cents: rpst.amount_cents,
                raw_pending_stripe_transaction_id: rpst.id
              }
              ct = ::CanonicalPendingTransaction.create!(attrs)
            end

          end
        end

        private

        def raw_pending_stripe_transactions_ready_for_processing
          @raw_pending_stripe_transactions_ready_for_processing ||= begin
            return RawPendingStripeTransaction.all if previously_processed_raw_pending_stripe_transactions_ids.length < 1

            RawPendingStripeTransaction.where('id not in(?)', previously_processed_raw_pending_stripe_transactions_ids)
          end
        end

        def previously_processed_raw_pending_stripe_transactions_ids
          @previously_processed_raw_pending_stripe_transactions_ids ||= ::CanonicalPendingTransaction.stripe.pluck(:raw_pending_stripe_transaction_id)
        end
      end
    end
  end
end
