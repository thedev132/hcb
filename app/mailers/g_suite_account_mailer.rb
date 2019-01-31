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

  def notify_creator_of_activation(params)
    @recipient = params[:recipient]
    @first_name = params[:first_name]
    @last_name = params[:last_name]

    mail to: @recipient,
      subject: "The Bank G Suite account that you created for #{@first_name} #{@last_name} has been activated."
  end

  def notify_user_of_reset(params)
    @recipient = params[:recipient]
    @address = params[:address]
    @password = params[:password]

    mail to: @recipient,
      subject: 'Bank G Suite password reset'
  end
end
