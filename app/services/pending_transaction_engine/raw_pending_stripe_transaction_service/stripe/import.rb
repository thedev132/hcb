# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class Import
        def initialize
        end

        def run
          ::Partners::Stripe::Issuing::Authorizations::List.new.run do |t|
            ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::ImportSingle.new(remote_stripe_transaction: t).run
          end

          nil
        end

      end
    end
  end
end
