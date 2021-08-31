# frozen_string_literal: true

class CanonicalPendingTransactionsController < ApplicationController
  def show
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])
    authorize @canonical_pending_transaction

    # Comments
    @hcb_code = HcbCode.find_or_create_by(hcb_code: @canonical_pending_transaction.hcb_code)
  end

  def edit
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])

    authorize @canonical_pending_transaction

    @event = @canonical_pending_transaction.event
  end

  def set_custom_memo
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])

    authorize @canonical_pending_transaction

    attrs = {
      canonical_pending_transaction_id: @canonical_pending_transaction.id,
      custom_memo: params[:canonical_pending_transaction][:custom_memo]
    }
    ::CanonicalPendingTransactionService::SetCustomMemo.new(attrs).run

    flash[:success] = "Renamed pending transaction"
    redirect_to @canonical_pending_transaction.local_hcb_code
  end

end
