# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class Import
        def initialize(created_after: nil)
          @created_after = created_after
        end

        def run
          authorizations = ::Partners::Stripe::Issuing::Authorizations::List.new(created_after: @created_after).run
          return if authorizations.empty?

          RawPendingStripeTransaction.upsert_all(authorizations.map { |authorization|
            {
              stripe_transaction_id: authorization[:id],
              stripe_transaction: authorization,
              amount_cents: -authorization[:amount],
              date_posted: Time.at(authorization[:created]),
            }
          }, unique_by: :stripe_transaction_id)

          nil
        end

      end
    end
  end
end
