class GSuiteMailerPreview < ActionMailer::Preview
  def notify_of_creation
    config = {
      g_suite: GSuite.last,
      recipient: GSuite.last.application.creator.email
    }
    GSuiteMailer.notify_of_creation(config)
  end
end