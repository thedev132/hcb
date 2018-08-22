class ApplicationMailer < ActionMailer::Base
  default from: 'Hack Club Bank <bank@hackclub.com>'
  layout 'mailer'

  # allow usage of application helper
  helper :application

  protected

  def admin_email
    env = Rails.env.production? ? :prod : :dev
    Rails.application.credentials.admin_email[env]
  end
end
