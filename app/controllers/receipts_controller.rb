class ReceiptsController < ApplicationController
  skip_after_action :verify_authorized, only: :upload # do not force pundit
  skip_before_action :signed_in_user, only: :upload
  before_action :set_paper_trail_whodunnit, only: :upload
  before_action :find_receiptable, only: [:upload, :mark_no_or_lost]

  def upload
    @receipt = @receiptable.receipts.create(params[:receipts])
    @receipt = Receipt.new(receipt_params)
    @receipt.user_id = current_user&.id || @receiptable.user.id

    @receipt.receiptable.marked_no_or_lost_receipt_at = nil

    if @receipt.save && @receipt.receiptable.save
      flash[:success] = 'Added receipt!'
      if current_user
        redirect_to @receiptable
      else
        redirect_back(fallback_location: @receiptable)
      end
    else
      flash[:error] = "Failed to upload receipt"
      redirect_back(fallback_location: @receiptable)
    end
  end

  def destroy
    @receipt = Receipt.find(params[:id])
    @receiptable = @receipt.receiptable
    authorize @receipt

    if @receipt.delete
      flash[:success] = "Deleted receipt"
      redirect_to @receiptable
    else
      flash[:error] = "Failed to delete receipt"
      redirect_to @receiptable
    end
  end

  private

  def receipt_params
    params.require(:receipt).permit(:file, :uploader, :receiptable_type, :receiptable_id)
  end

  def find_receiptable
    @klass = receipt_params[:receiptable_type].constantize
    @receiptable = @klass.find(receipt_params[:receiptable_id])
  end
end
