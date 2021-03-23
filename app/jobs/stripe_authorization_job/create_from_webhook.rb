# frozen_string_literal: true

module StripeAuthorizationJob
  class CreateFromWebhook < ApplicationJob
    def perform(stripe_transaction_id)
      # 1. fetch remote stripe transaction (authorization)
      remote_stripe_transaction = ::Partners::Stripe::Issuing::Authorizations::Show.new(id: stripe_transaction_id).run

      # 2. import into the db
      rpst = ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::ImportSingle.new(remote_stripe_transaction: remote_stripe_transaction).run

      # 3. canonize the newly added raw pending stripe transaction
      attrs = {
        date: rpst.date,
        memo: rpst.memo,
        amount_cents: rpst.amount_cents,
        raw_pending_stripe_transaction_id: rpst.id
      }
      ct = ::CanonicalPendingTransaction.create!(attrs)

      # 4. map to the event
      # TODO: 
    end
  end
end
