# frozen_string_literal: true

module Api
  module V4
    class InvitationsController < ApplicationController
      skip_after_action :verify_authorized, only: [:index]
      before_action :set_invitation, except: [:index, :create]

      def index
        @invitations = current_user.organizer_position_invites.pending
      end

      def show; end

      def create
        @event = Event.find_by_public_id(params[:event_id])
        authorize @event

        unless policy(@event).can_invite_user?
          return render json: { error: "You are not authorized to invite users" }, status: :forbidden
        end

        if @event.organizer_positions.exists?(user: User.find_by(email: params[:email]))
          return render json: { error: "User is already an organizer" }, status: :unprocessable_entity
        end

        if @event.organizer_position_invites.pending.exists?(email: params[:email])
          return render json: { error: "User already has a pending invitation" }, status: :unprocessable_entity
        end

        @invitation = OrganizerPositionInvite.new(
          event: @event,
          email: params[:email],
          position_role: params[:role],
          invited_by: current_user
        )

        if @invitation.save
          render :show, status: :created
        else
          render json: { errors: @invitation.errors }, status: :unprocessable_entity
        end
      end

      def accept
        unless @invitation.accept(show_onboarding: false)
          raise ActiveRecord::RecordInvalid.new(@invitation)
        end

        render :show
      end

      def reject
        unless @invitation.reject
          raise ActiveRecord::RecordInvalid.new(@invitation)
        end

        render :show
      end

      private

      def set_invitation
        @invitation = authorize OrganizerPositionInvite.find_by_public_id(params[:id]) || OrganizerPositionInvite.friendly.find(params[:id])

        if @invitation.cancelled? || @invitation.rejected? || @invitation.user != current_user
          raise ActiveRecord::RecordNotFound
        end
      end

    end
  end
end
