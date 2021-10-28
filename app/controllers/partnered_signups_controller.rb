# frozen_string_literal: true

class PartneredSignupsController < ApplicationController
  # POST /api/v1/connect/start
  # This is hit by the partner as part of the connect API
  def start
    # TODO
    @partner = Partner.find_by(api_key: params[:api_key])

    @partnered_signup = PartneredSignup.new(partner: @partner)

    if @partnered_signup.save
      render json: { "Error": "TODO: return partnered signup info" }
    else
      render json: { "Error": "TODO" }
    end
  end

  # GET /api/v1/connect/continue/:id
  def edit
    # TODO
  end

  # POST /api/v1/connect/finish/:id
  def update
    # TODO
    @partnered_signup = PartneredSignup.find(params[:id])
    @partnered_signup.update_attributes(partnered_signup_params)

    authorize @partnered_signup

    if @partnered_signup.save
      redirect_to @partnered_signup.redirect_url
    else
      render "edit"
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def partnered_signup_params
    # result_params = params.require(:partnered_signup).permit()
  end
end
