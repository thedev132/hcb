class OrganizerPositionsController < ApplicationController

  def delete
    @organizer_position = OrganizerPosition.find_by_id(params[:organizer_position_id])
    authorize @organizer_position
    @organizer_position.delete!
    flash[:success] = "Removed #{@organizer_position.user.email} from the team!"
    redirect_to event_team_path(@organizer_position.event)
  end

end
