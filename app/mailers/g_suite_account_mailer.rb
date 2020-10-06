class GSuiteAccountMailer < ApplicationMailer
  def verify
    @recipient = params[:recipient]

    mail to: @recipient,
         subject: '[Action Requested] Verify your Bank Google Workspace account'
  end

  def notify_user_of_activation(params)
    @recipient = params[:recipient]
    @address = params[:address]
    @password = params[:password]
    @event = params[:event]

    mail to: @recipient,
         subject: 'Your Google Workspace account via Bank is ready!'
  end

  def notify_user_of_reset(params)
    @recipient = params[:recipient]
    @address = params[:address]
    @password = params[:password]

    mail to: @recipient,
         subject: 'Your Bank Google Workspace password was reset'
  end
end
