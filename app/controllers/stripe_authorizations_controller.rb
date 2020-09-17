class StripeAuthorizationsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  skip_before_action :signed_in_user, only: [:receipt]
  skip_after_action :verify_authorized, only: [:receipt] # do not force pundit

  def index
    @stripe_authorizations = StripeAuthorization.includes(:event).all
    authorize @stripe_authorizations
  end

  def show
    @stripe_authorization = StripeAuthorization.includes(stripe_card: [:user, :event], receipts: :user).find(params[:id])
    authorize @stripe_authorization
    @event = @stripe_authorization.card.event

    @commentable = @stripe_authorization
    @comments = @commentable.comments.includes(:user)
    @comment = Comment.new
  end

  # Link sent in email to upload receipt without signing in
  def receipt
    @stripe_authorization = StripeAuthorization.includes(stripe_card: :event).find_by(stripe_id: params[:id])
    @event = @stripe_authorization.stripe_card.event
  end

  private

  def stripe_authorization_params
    params.require(:stripe_authorization).permit(receipts: [])
  end
end
