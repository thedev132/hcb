# frozen_string_literal: true

class OrganizerPositionInvitesController < ApplicationController
  before_action :set_opi, only: [:show, :accept, :reject, :cancel]

  skip_before_action :signed_in_user, only: [:show]
  skip_after_action :verify_authorized, only: [:show], if: -> { @skip_verfiy_authorized }

  def new
    @invite = OrganizerPositionInvite.new
    @invite.event = Event.friendly.find(params[:event_id])
    authorize @invite
  end

  def create
    event = Event.friendly.find(params[:event_id])

    @invite = OrganizerPositionInvite.new(invite_params)
    @invite.event = event
    @invite.sender = current_user

    # will be set to nil if not found, which is OK. see invite class for docs.
    @invite.user = User.find_by(email: invite_params[:email])

    authorize @invite

    if @invite.save
      flash[:success] = "Invite successfully sent to #{invite_params[:email]}"
      redirect_to event_team_path @invite.event
    else
      render "new"
    end
  end

  def show
    if signed_in?
      authorize @invite
      @organizers = @invite.event.organizer_positions.includes(:user)
      if @invite.cancelled?
        flash[:error] = "That invite was canceled!"
        redirect_to root_path
      end
    else
      hide_footer
      @skip_verfiy_authorized = true
      @prefill_email = @invite.email

      render "users/auth"
    end
  end

  def accept
    authorize @invite

    if @invite.accept
      redirect_to @invite.event
    else
      flash[:error] = "Failed to accept"
      redirect_to @invite
    end
  end

  def reject
    authorize @invite

    if @invite.reject
      flash[:success] = "You’ve rejected your invitation."
      redirect_to root_path
    else
      flash[:error] = "Failed to reject the invitation."
      redirect_to @invite
    end
  end

  def cancel
    authorize @invite

    if @invite.cancel
      flash[:success] = "#{@invite.email}\'s invitation has been canceled."
      redirect_to event_team_path(@invite.event)
    else
      flash[:error] = "Failed to cancel the invitation."
      redirect_to @invite.event
    end
  end

  private

  def set_opi
    @invite = OrganizerPositionInvite.friendly.find(params[:organizer_position_invite_id] || params[:id])
  end

  def invite_params
    params.require(:organizer_position_invite).permit(:email)
  end
end
