class GSuiteAccountMailer < ApplicationMailer
  def verify
    @recipient = params[:recipient]

    mail to: @recipient,
      subject: "[Action Requested] Verify your account"
  end
end
