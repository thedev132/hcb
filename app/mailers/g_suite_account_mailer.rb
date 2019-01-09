class GSuiteAccountMailer < ApplicationMailer
  def verify
    @recipient = params[:recipient]

    mail to: @recipient,
      subject: '[Action Requested] Verify your account'
  end

  def notify_user_of_activation(params)
    @recipient = params[:recipient]
    @address = params[:address]
    @password = params[:password]

    mail to: @recipient,
      subject: 'Your Bank G Suite account is ready for you!'
  end

  def notify_user_of_reset(params)
    @recipient = params[:recipient]
    @address = params[:address]
    @password = params[:password]

    mail to: @recipient,
      subject: 'Bank G Suite password reset'
  end
end
