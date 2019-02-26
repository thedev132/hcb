class ApplicationsController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user

  def apply
  end

  def submit
  end
end
