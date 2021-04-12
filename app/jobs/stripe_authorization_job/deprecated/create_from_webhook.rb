# frozen_string_literal: true

module StripeAuthorizationJob
  module Deprecated
    class CreateFromWebhook < ApplicationJob
      def perform(stripe_transaction_id)
        # DEPRECATED: create stripe auth on v1 engine
        #
        ::StripeAuthorization.create!(stripe_id: stripe_transaction_id)
      end
    end
  end
end
