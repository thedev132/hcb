# frozen_string_literal: true

class StripeAuthorizationMailer < ApplicationMailer
  def notify_admin_of_authorization
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event

    mail to: "bank-alerts@hackclub.com",
         subject: "#{@auth.status_emoji} Stripe authorization #{@auth.status_text.downcase} for card ##{@card.last4} (#{@event.name} | #{@user.full_name})"
  end

  def notify_user_of_decline
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event

    mail to: @user.email,
         subject: "#{@auth.status_emoji} Purchase #{@auth.status_text} at #{@auth.stripe_obj.merchant_data.name}"
  end

  def notify_user_of_approve
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event

    mail to: @user.email,
         subject: "Upload a receipt for your #{@auth.stripe_obj.authorization_method.humanize.downcase} transaction at #{@auth.stripe_obj.merchant_data.name}"
  end
end
