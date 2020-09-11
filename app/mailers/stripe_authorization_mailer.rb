class StripeAuthorizationMailer < ApplicationMailer
  def notify_admin_of_approve
    @auth_obj = params[:auth_obj]
    @card = StripeCard.find_by(stripe_id: @auth_obj[:card][:id])
    @user = @card.user

    mail to: admin_email,
         subject: "✅ Purchase approved"
  end

  def notify_admin_of_decline
    @auth_obj = params[:auth_obj]
    @card = StripeCard.find_by(stripe_id: @auth_obj[:card][:id])
    @user = @card.user

    mail to: admin_email,
         subject: "❌ Purchase declined"
  end

  def notify_user_of_decline
    @auth_obj = params[:auth_obj]
    @card = StripeCard.find_by(stripe_id: @auth_obj[:card][:id])
    @user = @card.user

    mail to: admin_email,
         subject: "❌ Purchase declined"
  end
end
