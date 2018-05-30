class TransactionsController < ApplicationController
  def show
    @transaction = Transaction.find(params[:id])
  end

  def edit
    @transaction = Transaction.find(params[:id])

    # so the fee relationship fields render
    @transaction.fee_relationship ||= FeeRelationship.new
  end

  def update
    @transaction = Transaction.find(params[:id])

    if @transaction.update(transaction_params)
      redirect_to @transaction.bank_account
    else
      render :edit
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      fee_relationship_attributes: [ :event_id ]
    )
  end
end
