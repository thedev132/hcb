# frozen_string_literal: true

class DocusignController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:signing_complete_redirect] # do not require logged in user

  def signing_complete_redirect
    hmac = params.require(:hmac)
    timestamp = params.require(:timestamp)
    role = params.fetch(:role, :recipient).to_sym
    partnered_signup_id = params.require(:partnered_signup_id)
    service = Partners::Docusign::SigningCompletionRedirect.new
    unless service.valid_webhook?(partnered_signup_id, timestamp, hmac, role)
      render json: { error: "invalid signature" }, status: :bad_request
      return
    end

    return handle_recipient_redirect(partnered_signup_id) if role == :recipient

    handle_admin_redirect(partnered_signup_id)
  end

  private

  def handle_recipient_redirect(partnered_signup_id)
    partnered_signup = PartneredSignup.find(partnered_signup_id)
    unless partnered_signup.signed_contract
      partnered_signup.submitted_at = Time.now
      partnered_signup.signed_contract = true
    end
    partnered_signup.save!

    # move to the redirect URL after submitting
    redirect_to partnered_signup.redirect_url
  end

  def handle_admin_redirect(partnered_signup_id)
    # TODO: download completed PDF + advance state-machine
    redirect_to partnered_signups_admin_index_url
  end

end
