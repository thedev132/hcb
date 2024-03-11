# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  OPERATIONS_EMAIL = "hcb@hackclub.com"

  DOMAIN = Rails.env.production? ? "hackclub.com" : "staging.hcb.hackclub.com"
  default from: "HCB <hcb@#{DOMAIN}>"
  layout "mailer/default"

  # allow usage of application helper
  helper :application

  protected

  def admin_email
    env = Rails.env.production? ? :prod : :dev
    Rails.application.credentials.admin_email[env]
  end

  def hcb_email_with_name_of(object)
    name = object.try(:name)
    if name.present?
      name += " via HCB"
    else
      name = "HCB"
    end

    email_address_with_name("hcb@hackclub.com", name)
  end

end
