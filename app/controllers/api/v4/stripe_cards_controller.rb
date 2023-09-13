# frozen_string_literal: true

module Api
  module V4
    class StripeCardsController < ApplicationController
      def index
        if params[:event_id].present?
          @event = Event.find_by_public_id(params[:event_id]) || Event.friendly.find(params[:event_id])
          @stripe_cards = @event.stripe_cards.includes(:user, :event).order(created_at: :desc)
        else
          @stripe_cards = current_user.stripe_cards.includes(:user, :event).order(created_at: :desc)
        end
      end

      def show
        @stripe_card = authorize StripeCard.find_by_public_id!(params[:id])
      end

      def update
        @stripe_card = authorize StripeCard.find_by_public_id!(params[:id])

        if params[:status] == "frozen"
          @stripe_card.freeze! unless @stripe_card.frozen?
        elsif params[:status] == "active"
          @stripe_card.defrost! unless @stripe_card.stripe_status == "active"
        end

        render "show"
      end

    end
  end
end
