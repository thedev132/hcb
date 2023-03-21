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
    # TODO: Pass through to signing if the form has already been submitted, but
    # contract has yet to be signed

    # Pass through to `redirect_url` if the form has already been signed
    redirect_to @partnered_signup.redirect_url, allow_other_host: true if @partnered_signup.applicant_signed?
  end

  # PATCH /partnered_signups/:public_id
  def update
    @partnered_signup.update_attributes(partnered_signup_params)
    authorize @partnered_signup

    @partnered_signup.mark_submitted! unless @partnered_signup.submitted?

    return unless signed_contract?

    redirect_to @partnered_signup.redirect_url, allow_other_host: true

    # Send webhook to let Partner know that the Connect from has been submitted
    ::PartneredSignupJob::DeliverWebhook.perform_later(@partnered_signup.id)
  rescue => e
    Airbrake.notify(e)
    render :edit, status: :unprocessable_entity
  end

  private

  # TODO: move some of this logic into the model and integrate the rest into the
  # controller update method
  def signed_contract?
    # Don't sign contract unless we have a docusign template id
    unless @partner.docusign_template_id
      @partnered_signup.mark_applicant_signed!

      # Airbrake.notify("Partner ##{@partner.id} is missing a 'docusign_template_id'. Error creating docusign contract for SUP ##{@partnered_signup.id}")
      # flash[:error] = "Something went wrong, please contact bank@hackclub.com for help"
      # render "edit"
      # TODO: error when there's no template ID, this is temporary until all partners have docusign templates
      return true
    end

    service = Partners::Docusign::PartneredSignupContract.new(@partnered_signup)

    # if we don't have the contract, send it
    unless @partnered_signup.docusign_envelope_id
      data = service.create
      @partnered_signup.docusign_envelope_id = data[:envelope].envelope_id
      if @partnered_signup.save
        redirect_to data[:signing_url], allow_other_host: true
      else
        flash.now[:error] = "Something went wrong, please contact bank@hackclub.com for help"
        render :edit, status: :unprocessable_entity
      end
      return false
    end

    # if the user didn't sign the contract yet, show it to them again
    unless @partnered_signup.signed_contract
      redirect_to service.get_signing_url(@partnered_signup.docusign_envelope_id), allow_other_host: true
    end
    false
  end

  def set_partnered_signup
    @partnered_signup = PartneredSignup.find_by_public_id(params[:public_id])
  end

  def set_partner
    @partner = @partnered_signup.partner
  end

  # Only allow a trusted parameter "white list" through.
  def partnered_signup_params
    params.require(:partnered_signup).permit(
      :organization_name,
      :owner_name,
      :owner_phone,
      :owner_email,
      :owner_address_line1,
      :owner_address_line2,
      :owner_address_city,
      :owner_address_state,
      :owner_address_postal_code,
      :owner_address_country,
      :owner_birthdate,
    )
  end

end
