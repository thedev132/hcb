class EmburseTransactionsController < ApplicationController
  before_action :skip_authorization, only: [ :stats ]
  before_action :set_emburse_transaction, only: [ :show, :edit, :update ]

  def stats
    render json: {
      total_card_spend: EmburseTransaction.total_card_transaction_volume,
      total_card_transaction_count: EmburseTransaction.total_card_transaction_count
    }
  end

  def index
    authorize EmburseTransaction
    all_et = EmburseTransaction.undeclined.order(created_at: :desc)
    @emburse_transactions = all_et.where(event_id: nil) + all_et.where.not(event_id: nil)
  end

  def show
  end

  def edit
    @amount = @emburse_transaction.amount / 100.0
  end

  def update
    result_params = emburse_transaction_params
    result_params[:amount] = result_params[:amount].to_f * 100.0
    if @emburse_transaction.update(result_params)
      flash[:success] = 'Emburse Transaction successfully updated.'
      redirect_to emburse_transactions_path
    else
      render :edit
    end
  end

  private

  def emburse_transaction_params
    params.require(:emburse_transaction).permit(:amount, :event_id)
  end

  def set_emburse_transaction
    @emburse_transaction = EmburseTransaction.find(params[:id])
    authorize @emburse_transaction
  end
end
