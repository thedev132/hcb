# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  OPERATIONS_EMAIL = "bank-alert@hackclub.com"

  default from: "Hack Club Bank <bank@hackclub.com>"
  layout "mailer"

  # allow usage of application helper
  helper :application

  protected

  def admin_email
    env = Rails.env.production? ? :prod : :dev
    Rails.application.credentials.admin_email[env]
  end
end
