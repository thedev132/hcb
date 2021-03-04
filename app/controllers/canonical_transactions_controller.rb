require 'csv'

class CanonicalTransactionsController < ApplicationController
  def show
    @canonical_transaction = CanonicalTransaction.find(params[:id])

    authorize @canonical_transaction

    redirect_to transaction_url(params[:id])
  end

  def edit
    @canonical_transaction = CanonicalTransaction.find(params[:id])

    authorize @canonical_transaction

    @event = @canonical_transaction.event
  end

  def set_custom_memo
    @canonical_transaction = CanonicalTransaction.find(params[:id])

    authorize @canonical_transaction

    attrs = {
      canonical_transaction_id: @canonical_transaction.id,
      custom_memo: params[:canonical_transaction][:custom_memo]
    }
    ::CanonicalTransactionService::SetCustomMemo.new(attrs).run

    redirect_to transaction_url(params[:id])
  end

  def waive_fee
    authorize CanonicalTransaction

    ct = CanonicalTransaction.find(params[:id])

    fee = ct.canonical_event_mapping.fees.first
    fee.amount_cents_as_decimal = 0
    fee.reason = "REVENUE WAIVED"
    fee.save!

    redirect_to transaction_url(params[:id])
  end

  def unwaive_fee
    authorize CanonicalTransaction

    ct = CanonicalTransaction.find(params[:id])

    raise ArgumentError unless ct.amount_cents > 0

    fee = ct.canonical_event_mapping.fees.first
    fee.amount_cents_as_decimal = BigDecimal("#{ct.amount_cents}") * BigDecimal("#{ct.event.sponsorship_fee}")

    fee.reason = "REVENUE"
    fee.save!

    redirect_to transaction_url(params[:id])
  end

  def mark_bank_fee
    authorize CanonicalTransaction

    ct = CanonicalTransaction.find(params[:id])

    fee = ct.canonical_event_mapping.fees.first
    fee.reason = "HACK CLUB FEE"
    fee.save!

    redirect_to transaction_url(params[:id])
  end

end
