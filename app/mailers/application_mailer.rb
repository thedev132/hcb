# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  OPERATIONS_EMAIL = "hcb@hackclub.com"

  default from: "HCB <hcb@hackclub.com>"
  layout "mailer/default"

  # allow usage of application helper
  helper :application

  protected

  def admin_email
    env = Rails.env.production? ? :prod : :dev
    Rails.application.credentials.admin_email[env]
  end

end
