class OrganizerPositionsController < ApplicationController
  def destroy
    @organizer_position = OrganizerPosition.find(params[:id])
    authorize @organizer_position
    @organizer_position.destroy
    flash[:success] = "Removed #{@organizer_position.user.email} from the team!"
    redirect_to event_team_path(@organizer_position.event)
  end
end
