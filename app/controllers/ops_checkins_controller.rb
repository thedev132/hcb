# frozen_string_literal: true

class OpsCheckinsController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit

  def create
    @ops_checkin = OpsCheckin.new(point_of_contact_id: current_user&.id)

    # authorize @ops_checkin

    if @ops_checkin.save
      flash[:success] = "Checkin recorded"
      redirect_to root_path
    else
      flash[:error] = @ops_checkin.errors
      redirect_to admin_tasks_path
    end
  end
end
