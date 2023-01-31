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
    @suggested_memos = ::HcbCodeService::SuggestedMemos.new(hcb_code: @canonical_pending_transaction.local_hcb_code, event: @event).run.first(4)
  end

  def set_custom_memo
    @canonical_pending_transaction = CanonicalPendingTransaction.find(params[:id])

    authorize @canonical_pending_transaction

    attrs = {
      canonical_pending_transaction_id: @canonical_pending_transaction.id,
      custom_memo: params[:canonical_pending_transaction][:custom_memo]
    }
    ::CanonicalPendingTransactionService::SetCustomMemo.new(attrs).run

    if @current_user.admin?
      @canonical_pending_transaction.update(fronted: params[:canonical_pending_transaction][:fronted])
    end

    flash[:success] = "Renamed pending transaction"
    redirect_to @canonical_pending_transaction.local_hcb_code
  end

end
