class OrganizerPositionInvitesController < ApplicationController
  before_action :signed_in_user

  def new
    @invite = OrganizerPositionInvite.new
    @invite.event = Event.find(params[:event_id])
  end

  def create
    event = Event.find(params[:event_id])

    @invite = OrganizerPositionInvite.new(invite_params)
    @invite.event = event
    @invite.sender = current_user

    # will be set to nil if not found, which is OK. see invite class for docs.
    @invite.user = User.find_by(email: invite_params[:email])

    authorize @invite

    if @invite.save
      flash[:success] = 'Invite successfully sent'
      redirect_to @invite.event
    else
      render :new
    end
  end

  def show
    @invite = OrganizerPositionInvite.find(params[:id])
    authorize @invite
  end

  def accept
    @invite = OrganizerPositionInvite.find(params[:organizer_position_invite_id])
    authorize @invite

    if @invite.accept
      flash[:success] = 'You’ve accepted your invitation!'
      redirect_to @invite.event
    else
      flash[:error] = 'Failed to accept'
      redirect_to @invite
    end
  end

  def reject
    @invite = OrganizerPositionInvite.find(params[:organizer_position_invite_id])
    authorize @invite

    if @invite.reject
      flash[:success] = 'You’ve rejected your invitation.'
      redirect_to root_path
    else
      flash[:error] = 'Failed to reject the invitation.'
      redirect_to @invite
    end
  end

  private

  def invite_params
    params.require(:organizer_position_invite).permit(:email)
  end
end
