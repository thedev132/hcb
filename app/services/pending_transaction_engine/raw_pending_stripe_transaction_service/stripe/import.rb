# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingStripeTransactionService
    module Stripe
      class Import
        def initialize
        end

        def run
          pending_stripe_transactions.each do |t|
            ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::ImportSingle.new(remote_stripe_transaction: t).run
          end

          nil
        end

        private

        def pending_stripe_transactions
          @pending_stripe_transactions ||= ::Partners::Stripe::Issuing::Authorizations::List.new.run
        end
      end
    end
  end
end
