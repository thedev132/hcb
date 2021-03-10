class CanonicalPendingTransactionsController < ApplicationController
  def show
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])

    authorize @canonical_pending_transaction
  end
end
