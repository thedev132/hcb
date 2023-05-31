# frozen_string_literal: true

module StripeAuthorizationService
  module Webhook
    class HandleIssuingAuthorizationRequest
      def initialize(stripe_event:)
        @stripe_event = stripe_event
      end

      def run
        approve?
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
        @card ||= StripeCard.includes(:card_grant).find_by(stripe_id: stripe_card_id)
      end

      def event
        card.event
      end

      def decline_with_reason!(reason)
        StripeService::Issuing::Authorization.update(auth_id, { metadata: { declined_reason: reason } })
        return false
      end

      def approve?
        return decline_with_reason!("inadequate_balance")   if card.balance_available < amount_cents
        return decline_with_reason!("merchant_not_allowed") if card.card_grant&.merchant_lock.present? && card.card_grant.merchant_lock != auth[:merchant_data][:network_id] # Handle merchant locks for restricted grants

        true
      end

    end
  end
end
