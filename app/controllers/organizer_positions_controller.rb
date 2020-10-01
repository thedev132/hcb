class OrganizerPositionsController < ApplicationController
  def destroy
    @organizer_position = OrganizerPosition.find(params[:id])
    authorize @organizer_position
    @organizer_position.destroy

    # also remove all organizer invites from the organizer that are still pending
    invites = @organizer_position.event.organizer_position_invites.pending.where(sender: @organizer_position.user)
    invites.each do |ivt|
      ivt.cancel
    end

    flash[:success] = "Removed #{@organizer_position.user.email} from the team."
    redirect_back(fallback_location: event_team_path(@organizer_position.event))
  end
end
