class LoadCardRequestMailer < ApplicationMailer
  def admin_notification
    @lcr = params[:load_card_request]
    @event = @lcr.event

    mail to: admin_email, subject: 'Balance transfer received'
  end
end
