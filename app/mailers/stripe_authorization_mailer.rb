class StripeAuthorizationMailer < ApplicationMailer
  def notify_admin_of_authorization
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event

    mail to: admin_email,
         subject: "#{@auth.status_emoji} Stripe authorization #{@auth.status_text.downcase} for card ##{@card.last4} (#{@event.name} | #{@user.full_name})"
  end

  def notify_user_of_decline
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event

    mail to: @user.email,
         subject: "#{@auth.status_emoji} Purchase #{@auth.status_text}"
  end
end
