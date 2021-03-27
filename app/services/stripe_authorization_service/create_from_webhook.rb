# frozen_string_literal: true

module StripeAuthorizationService
  class CreateFromWebhook
    def initialize(stripe_transaction_id:)
      @stripe_transaction_id = stripe_transaction_id
    end

    def run
      ActiveRecord::Base.transaction do
        # 1. fetch remote stripe transaction (authorization)
        remote_stripe_transaction = ::Partners::Stripe::Issuing::Authorizations::Show.new(id: @stripe_transaction_id).run
        return unless remote_stripe_transaction

        # 2. idempotent import into the db
        rpst = ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::ImportSingle.new(remote_stripe_transaction: remote_stripe_transaction).run

        # 3. idempotent canonize the newly added raw pending stripe transaction
        cpt = ::PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::Stripe.new(raw_pending_stripe_transaction: rpst).run

        # 4. idempotent map to event
        ::PendingEventMappingEngine::Map::Single::Stripe.new(canonical_pending_transaction: cpt).run
      end

      # send cpt mailer(s)
    end
  end
end
