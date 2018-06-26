class StaticPagesController < ApplicationController
  def index
    if signed_in?
      @events = current_user.events
      @invites = current_user.organizer_position_invites.pending
    end
  end
end
