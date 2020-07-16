# Preview all emails at http://localhost:3000/rails/mailers/g_suite_mailer
class GSuiteMailerPreview < ActionMailer::Preview
  # Preview notify_of_creation at http://localhost:3000/rails/mailers/g_suite_mailer/notify_of_creation
  def notify_of_creation
    config = {
      g_suite: GSuite.last,
      recipient: GSuite.last.application.creator.email
    }
    GSuiteMailer.notify_of_creation(config)
  end
end