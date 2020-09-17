class StripeAuthorizationsController < ApplicationController
  def show
    @stripe_authorization = StripeAuthorization.find params[:id]
    authorize @stripe_authorization
  end

  def index
    @stripe_authorizations = StripeAuthorization.all
    authorize @stripe_authorizations
  end
end