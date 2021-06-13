class FeeReimbursementsController < ApplicationController
  before_action :set_fee_reimbursement, only: [:show, :edit, :update, :destroy, :mark_as_processed, :mark_as_unprocessed]

  # GET /fee_reimbursements/1
  def show
    if @fee_reimbursement.invoice
      @event = @fee_reimbursement.event
    else
      @event = @fee_reimbursement.event
    end
    authorize @fee_reimbursement

    @commentable = @fee_reimbursement
    @comments = @commentable.comments
    @comment = Comment.new
  end

  # GET /fee_reimbursements/1/edit
  def edit
    authorize @fee_reimbursement
  end

  # PATCH/PUT /fee_reimbursements/1
  def update
    authorize @fee_reimbursement

    # Load amount is in cents on the backend, but dollars on the frontend
    result_params = fee_reimbursement_params
    result_params[:amount] = result_params[:amount].to_f * 100

    if @fee_reimbursement.update(result_params)
      redirect_to @fee_reimbursement, notice: 'Fee refund was successfully updated.'
    else
      render :edit
    end
  end

  def mark_as_unprocessed
    @fee_reimbursement.processed_at = nil

    authorize @fee_reimbursement

    if @fee_reimbursement.save
      flash[:success] = 'Marked as unprocessed.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to @fee_reimbursement
  end

  def mark_as_processed
    @fee_reimbursement.processed_at = Time.now

    authorize @fee_reimbursement

    if @fee_reimbursement.save
      flash[:success] = 'Marked as processed.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to @fee_reimbursement
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_fee_reimbursement
    @fee_reimbursement = FeeReimbursement.find(params[:fee_reimbursement_id] || params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def fee_reimbursement_params
    params.require(:fee_reimbursement).permit(:amount, :status, :transaction_memo)
  end
end
