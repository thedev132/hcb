class EmburseTransfersController < ApplicationController
  before_action :set_emburse_transfer, only: [:show, :edit, :update, :reject, :cancel, :accept]
  skip_before_action :signed_in_user

  def export
    authorize EmburseTransfer

    emburse_transfers = EmburseTransfer.under_review

    attributes = %w{load_amount emburse_memo}

    result = CSV.generate(headers: true) do |csv|
      csv << attributes.map

      emburse_transfers.each do |emburse_transfer|
        csv << attributes.map do |attr|
          if attr == 'load_amount'
            emburse_transfer.load_amount.to_f / 100
          elsif attr == 'emburse_memo'
            "Transfer request ID##{emburse_transfer.id}"
          else
            cr.send(attr)
          end
        end
      end
    end

    send_data result, filename: "Pending emburse_transfers #{Date.today}.csv"
  end

  def index
    @emburse_transfers = EmburseTransfer.all.order(created_at: :desc).page params[:page]
    authorize @emburse_transfers
  end

  def show
    @event = @emburse_transfer.event
    authorize @emburse_transfer

    @commentable = @emburse_transfer
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def edit
    authorize @emburse_transfer
  end

  def update
    authorize @emburse_transfer

    # Load amount is in cents on the backend, but dollars on the frontend
    result_params = emburse_transfer_params
    result_params[:load_amount] = result_params[:load_amount].to_f * 100

    if @emburse_transfer.update(result_params)
      flash[:success] = 'Transfer request was successfully updated.'
      redirect_to @emburse_transfer
    else
      render :edit
    end
  end

  def accept
    @emburse_transfer.accepted_at = Time.now
    @emburse_transfer.fulfilled_by = current_user

    authorize @emburse_transfer

    if @emburse_transfer.save
      flash[:success] = 'Transfer accepted.'
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to emburse_transfers_path
  end

  def reject
    authorize @emburse_transfer

    @emburse_transfer.rejected_at = Time.now
    if @emburse_transfer.save
      flash[:success] = 'Transfer rejected.'
      redirect_to @emburse_transfer.event
    else
      redirect_to emburse_transfers_path
    end
  end

  def cancel
    authorize @emburse_transfer

    if @emburse_transfer.under_review?
      @emburse_transfer.canceled_at = Time.now
      if @emburse_transfer.save
        flash[:success] = 'Transfer canceled.'
      else
        flash[:error] = 'Failed to cancel transfer.'
      end
    else
      flash[:error] = 'Transfer cannot be canceled.'
    end

    redirect_to event_emburse_cards_overview_path(@emburse_transfer.event)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_emburse_transfer
    @emburse_transfer = EmburseTransfer.find(params[:id] || params[:emburse_transfer_id])
    @event = @emburse_transfer.event
  end

  # Only allow a trusted parameter "white list" through.
  def emburse_transfer_params
    params.require(:emburse_transfer).permit(:event_id, :creator_id, :load_amount, :emburse_transaction_id)
  end
end
