# frozen_string_literal: true

module StripeAuthorizationService
  module Webhook
    class HandleIssuingAuthorizationRequest
      def initialize(stripe_event:)
        @stripe_event = stripe_event
      end

      def run
        # 1. approve or decline
        if approve?
          StripeService::Issuing::Authorization.approve(auth_id)
        else
          StripeService::Issuing::Authorization.decline(auth_id)
        end

        # 2. create stripe authorization (v1 engine)
        ::StripeAuthorization.create!(stripe_id: auth_id) # TODO: move to background job

        # 3. put the transaction on the pending ledger in almost realtime
        ::StripeAuthorizationJob::CreateFromWebhook.perform_later(auth_id) # 
      end

      private

      def auth
        @stripe_event[:data][:object]
      end

      def auth_id
        auth[:id]
      end

      def amount_cents
        auth[:pending_request][:amount]
      end

      def stripe_card_id
        auth[:card][:id]
      end

      def card
        @card ||= StripeCard.find_by(stripe_id: stripe_card_id)
      end

      def event
        card.event
      end

      def approve?
        event.balance_available_v2_cents >= amount_cents
      end
    end
  end
end
