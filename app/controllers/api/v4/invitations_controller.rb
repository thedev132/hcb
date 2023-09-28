# frozen_string_literal: true

module Api
  module V4
    class InvitationsController < ApplicationController
      skip_after_action :verify_authorized, only: [:index]
      before_action :set_invitation, except: [:index]

      def index
        @invitations = current_user.organizer_position_invites.pending
      end

      def show; end

      def accept
        unless @invitation.accept
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
        @invitation = authorize OrganizerPositionInvite.find_by_public_id!(params[:id])
      end

    end
  end
end
