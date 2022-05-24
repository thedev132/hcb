# frozen_string_literal: true

class GSuiteAccountMailerPreview < ActionMailer::Preview
  def verify
    @recipient = GSuiteAccount.last
    GSuiteAccountMailer.with(recipient: @recipient.address).verify
  end

  def notify_user_of_activation
    @recipient = GSuiteAccount.last
    GSuiteAccountMailer.notify_user_of_activation(
      recipient: @recipient.address,
      address: @recipient.address,
      password: @recipient.initial_password,
      event: @recipient.g_suite.event.name
    )
  end

  def notify_user_of_reset
    @recipient = GSuiteAccount.last
    GSuiteAccountMailer.notify_user_of_reset(
      recipient: @recipient.address,
      address: @recipient.address,
      password: @recipient.initial_password
    )
  end

end
