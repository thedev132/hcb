# frozen_string_literal: true

class StripeAuthorizationMailer < ApplicationMailer
  def notify_user_of_decline
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event
    @merchant = params[:merchant] || @auth.stripe_obj.merchant_data.name

    mail to: @user.email,
         subject: "#{@auth.status_emoji} Purchase #{@auth.status_text} at #{@merchant}"
  end

  def notify_user_of_approve
    auth_id = params[:auth_id]
    @auth = StripeAuthorization.find(auth_id)
    @card = @auth.card
    @user = @card.user
    @event = @card.event
    @authorization_method = params[:authorization_method] || @auth.stripe_obj.authorization_method.humanize.downcase
    @merchant = params[:merchant] || @auth.stripe_obj.merchant_data.name

    mail to: @user.email,
         subject: "Upload a receipt for your #{@authorization_method} transaction at #{@merchant}"
  end

end
