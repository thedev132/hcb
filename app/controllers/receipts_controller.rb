class ReceiptsController < ApplicationController
  skip_after_action :verify_authorized, only: :upload # do not force pundit
  skip_before_action :signed_in_user, only: :upload
  before_action :set_paper_trail_whodunnit, only: :upload

  def upload
    @stripe_authorization = StripeAuthorization.find(params[:stripe_authorization_id])
    @receipt = Receipt.new(receipt_params)
    @receipt.user_id = current_user&.id || @stripe_authorization.card.user.id

    if @receipt.save
      flash[:success] = "Receipts uploaded!"
      redirect_to @stripe_authorization
    else
      flash[:error] = "Failed to upload receipt"
      redirect_to stripe_authorization_path(@stripe_authorization)
    end
  end

  def destroy
    @receipt = Receipt.find(params[:id])
    @stripe_authorization = @receipt.stripe_authorization
    authorize @receipt

    if @receipt.delete
      flash[:success] = "Deleted receipt"
      redirect_to @stripe_authorization
    else
      flash[:error] = "Failed to delete receipt"
      redirect_to @stripe_authorization
    end
  end

  private

  def receipt_params
    params.require(:receipt).permit(:file, :uploader, :stripe_authorization_id)
  end
end
