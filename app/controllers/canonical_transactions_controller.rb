require 'csv'

class CanonicalTransactionsController < ApplicationController
  def show
    authorize CanonicalTransaction

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

  def mark_bank_fee
    authorize CanonicalTransaction

    ct = CanonicalTransaction.find(params[:id])

    fee = ct.canonical_event_mapping.fees.first
    fee.reason = "HACK CLUB FEE"
    fee.save!

    redirect_to transaction_url(params[:id])
  end

end
