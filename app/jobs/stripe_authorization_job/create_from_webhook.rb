# frozen_string_literal: true

module StripeAuthorizationJob
  class CreateFromWebhook < ApplicationJob
    def perform(stripe_transaction_id)
      ::StripeAuthorizationService::CreateFromWebhook.new(stripe_transaction_id: stripe_transaction_id).run
    end
  end
end
