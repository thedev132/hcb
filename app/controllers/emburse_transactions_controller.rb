class EmburseTransactionsController < ApplicationController
  before_action :skip_authorization

  def stats
    render json: {
      total_card_spend: EmburseTransaction.total_card_transaction_volume,
      total_card_transaction_count: EmburseTransaction.total_card_transaction_count
    }
  end
end
