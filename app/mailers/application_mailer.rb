class ApplicationMailer < ActionMailer::Base
  default from: 'Hack Club Bank <bank@hackclub.com>'
  layout 'mailer'

  # allow usage of application helper
  helper :application
end
