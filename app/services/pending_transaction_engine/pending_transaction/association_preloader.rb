# frozen_string_literal: true

module PendingTransactionEngine
  module PendingTransaction
    class AssociationPreloader
      def initialize(pending_transactions:, event:)
        @pending_transactions = pending_transactions
        @event = event
      end

      def run!
        preload_associations!
      end

      def preload_associations!
        stripe_ids = @pending_transactions.filter_map do |pt|
          if pt.raw_pending_stripe_transaction
            pt.raw_pending_stripe_transaction.stripe_transaction["cardholder"]
          end
        end
        stripe_cardholders_by_stripe_id = ::StripeCardholder.includes(:user).where(stripe_id: stripe_ids).index_by(&:stripe_id)

        @pending_transactions.each do |pt|
          if pt.raw_pending_stripe_transaction
            pt.stripe_cardholder = stripe_cardholders_by_stripe_id[pt.raw_pending_stripe_transaction.stripe_transaction["cardholder"]]
          end
        end
      end

    end
  end
end
