class GSuiteAccountMailerPreview < ActionMailer::Preview
  def verify
    config = {
      recipient: GSuiteAccount.last.address
    }
    GSuiteAccountMailer.with(config).send __method__
  end
end