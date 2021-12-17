# frozen_string_literal: true

class DocusignController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:signing_complete_redirect] # do not require logged in user

  def signing_complete_redirect
    hmac = params.require(:hmac)
    timestamp = params.require(:timestamp)
    partnered_signup_id = params.require(:partnered_signup_id)
    service = Partners::Docusign::SigningCompletionRedirect.new
    unless service.valid_webhook?(partnered_signup_id, timestamp, hmac)
      render json: { error: "invalid signature" }, status: :bad_request
      return
    end
    partnered_signup = PartneredSignup.find(partnered_signup_id)
    unless partnered_signup.signed_contract
      partnered_signup.submitted_at = Time.now
      partnered_signup.signed_contract = true
    end
    partnered_signup.save!

    # move to the redirect URL after submitting
    redirect_to partnered_signup.redirect_url
  end
end
