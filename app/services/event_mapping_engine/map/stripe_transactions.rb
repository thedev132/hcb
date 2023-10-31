# frozen_string_literal: true

module EventMappingEngine
  module Map
    class StripeTransactions
      include ::TransactionEngine::Shared

      def initialize(start_date: nil)
        @start_date = start_date || last_1_month
      end

      def run
        CanonicalTransaction.unmapped.where("date >= ?", @start_date).stripe_transaction.find_each(batch_size: 100) do |ct|
          Single::Stripe.new(canonical_transaction: ct).run
        end
      end

    end
  end
end
