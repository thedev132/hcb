# frozen_string_literal: true

class PartneredSignupsController < ApplicationController
  before_action :set_partnered_signup, only: [:edit, :update]
  before_action :set_partner, only: [:edit, :update]
  skip_after_action :verify_authorized, only: [:edit, :update]
  skip_before_action :signed_in_user, only: [:edit, :update]

  # POST /api/v1/partnered_signups/new ..... NOT!
  def start
    # Are you looking for start? Psych! It's not here!
    # This controller manages all the views for the partner signup process, but the v1_controller manages all the JSON API endpoints
  end

  # GET /api/v1/partnered_signups/continue/:public_id
  # GET /partnered_signups/:public_id
  def edit
    # Pass through to `redirect_url` if the form has already been submitted
    redirect_to @partnered_signup.redirect_url if @partnered_signup.submitted?
  end

  # PATCH /partnered_signups/:public_id
  def update
    @partnered_signup.update_attributes(partnered_signup_params)
    @partnered_signup.submitted_at = Time.now

    authorize @partnered_signup

    if @partnered_signup.save
      redirect_to @partnered_signup.redirect_url

      # Send webhook to let Partner know that the Connect from has been submitted
      ::PartneredSignupJob::DeliverWebhook.perform_later(@partnered_signup.id)
    else
      render "edit"
    end
  end

  private

  def set_partnered_signup
    @partnered_signup = PartneredSignup.find_by_public_id(params[:public_id])
  end

  def set_partner
    @partner = @partnered_signup.partner
  end

  # Only allow a trusted parameter "white list" through.
  def partnered_signup_params
    result_params = params.require(:partnered_signup).permit(
      :organization_name,
      :owner_name,
      :owner_phone,
      :owner_email,
      :owner_address,
      :owner_birthdate,
    )
  end
end
