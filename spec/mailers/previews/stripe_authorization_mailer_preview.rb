# frozen_string_literal: true

class StripeAuthorizationMailerPreview < ActionMailer::Preview
  def notify_user_of_decline
    @auth_id = StripeAuthorization.declined.last.id
    @merchant = "EXAMPLE MERCHANT"
    StripeAuthorizationMailer.with(
      auth_id: @auth_id,
      merchant: @merchant
    ).notify_user_of_decline
  end

  def notify_user_of_approve
    @auth_id = StripeAuthorization.approved.last.id
    @merchant = "EXAMPLE MERCHANT"
    @authorization_method = "chip"
    StripeAuthorizationMailer.with(
      auth_id: @auth_id,
      merchant: @merchant,
      authorization_method: @authorization_method
    ).notify_user_of_approve
  end

end
