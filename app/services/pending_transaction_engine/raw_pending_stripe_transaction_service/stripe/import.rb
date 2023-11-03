# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class Import
        def initialize(created_after: nil)
          @created_after = created_after
        end

        def run
          ::Partners::Stripe::Issuing::Authorizations::List.new(created_after: @created_after).run do |t|
            ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::ImportSingle.new(remote_stripe_transaction: t).run
          end

          nil
        end

      end
    end
  end
end
