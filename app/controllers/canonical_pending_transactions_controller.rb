class CanonicalPendingTransactionsController < ApplicationController
  def show
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])

    # Comments
    @commentable = HcbCode.find_by(hcb_code: @canonical_pending_transaction.hcb_code)

    if @commentable
      @comments = @commentable.comments
      @comment = Comment.new
    end

    authorize @canonical_pending_transaction
  end
end
