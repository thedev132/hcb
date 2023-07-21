# frozen_string_literal: true

module Api
  module V4
    class StripeCardsController < ApplicationController
      def index
        if params[:event_id].present?
          @event = Event.find_by_public_id(params[:event_id]) || Event.friendly.find(params[:event_id])
          @stripe_cards = @event.stripe_cards.includes(:user, :event)
        else
          @stripe_cards = current_user.stripe_cards.includes(:user, :event)
        end
      end

      def show
        @stripe_card = authorize StripeCard.find_by_public_id!(params[:id])
      end

    end
  end
end
