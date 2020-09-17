class StripeAuthorizationsController < ApplicationController
  before_action :set_paper_trail_whodunnit

  def show
    @stripe_authorization = StripeAuthorization.includes(stripe_card: :user, receipts: :user).find(params[:id])
    authorize @stripe_authorization

    @commentable = @stripe_authorization
    @comments = @commentable.comments.includes(:user)
    @comment = Comment.new
  end

  def index
    @stripe_authorizations = StripeAuthorization.includes(:event).all
    authorize @stripe_authorizations
  end

  private

  def stripe_authorization_params
    params.require(:stripe_authorization).permit(receipts: [])
  end
end
