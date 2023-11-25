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

      def card_balance_available
        @card_balance_available ||= card.balance_available
      end

      def event
        card.event
      end

      def decline_with_reason!(reason)
        set_metadata!(declined_reason: reason)

        false
      end

      def approve?
        return decline_with_reason!("inadequate_balance") if card_balance_available < amount_cents

        if card&.card_grant&.allowed_categories&.exclude?(auth[:merchant_data][:category])
          return decline_with_reason!("merchant_not_allowed")
        end

        if card&.card_grant&.allowed_merchants&.exclude?(auth[:merchant_data][:network_id])
          return decline_with_reason!("merchant_not_allowed")
        end

        set_metadata!

        true
      end

      def set_metadata!(additional = {})
        default_metadata = {
          current_balance_available: card_balance_available,
        }

        StripeService::Issuing::Authorization.update(
          auth_id,
          { metadata: default_metadata.deep_merge(additional) }
        )
      end

    end
  end
end
