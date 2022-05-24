# frozen_string_literal: true

class GSuiteMailerPreview < ActionMailer::Preview
  def notify_of_configuring
    g_suite = GSuite.configuring.last
    g_suite ||= GSuite.last
    @g_suite_id = g_suite.id
    @recipient = g_suite.created_by.email
    GSuiteMailer.with(
      recipient: @recipient,
      g_suite_id: @g_suite_id
    ).notify_of_configuring
  end

  def notify_of_verified
    g_suite = GSuite.verified.last
    g_suite ||= GSuite.last
    @g_suite_id = g_suite.id
    @recipient = g_suite.created_by.email
    GSuiteMailer.with(
      recipient: @recipient,
      g_suite_id: @g_suite_id
    ).notify_of_verified
  end

end
