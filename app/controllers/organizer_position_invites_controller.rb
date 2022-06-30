# frozen_string_literal: true

class OrganizerPositionInvitesController < ApplicationController
  include SetEvent

  before_action :set_opi, only: [:show, :accept, :reject, :cancel]
  before_action :set_event, only: [:new, :create]
  before_action :hide_footer, only: :show

  skip_before_action :signed_in_user, only: [:show]
  skip_after_action :verify_authorized, only: [:show], if: -> { @skip_verfiy_authorized }

  def new
    service = OrganizerPositionInviteService::Create.new(event: @event)

    @invite = service.model
    authorize @invite
  end

  def create
    user_email = invite_params[:email]

    service = OrganizerPositionInviteService::Create.new(event: @event, sender: current_user, user_email: user_email)

    @invite = service.model

    authorize @invite

    if service.run
      flash[:success] = "Invite successfully sent to #{user_email}"
      redirect_to event_team_path @invite.event
    else
      render "new"
    end
  end

  def show
    # If the user's not signed in, redirect them to login page
    unless signed_in?
      hide_footer
      @skip_verfiy_authorized = true
      @prefill_email = @invite.email

      render "users/auth" and return
    end

    authorize @invite
    @organizers = @invite.event.organizer_positions.includes(:user)
    if @invite.cancelled?
      flash[:error] = "This invitation has been canceled."
      redirect_to root_path
    elsif @invite.accepted?
      redirect_to @invite.event, flash: { success: "You’ve already joined this team!" }
    elsif @invite.rejected?
      redirect_to root_path, flash: { error: "You’ve already rejected this invitation." }
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
