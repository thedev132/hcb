require 'csv'

class CanonicalTransactionsController < ApplicationController
  def show
    authorize CanonicalTransaction

    redirect_to transaction_url(params[:id])
  end

  def waive_fee
    authorize CanonicalTransaction

    @canonical_transaction = CanonicalTransaction.find(params[:id])

    fee = @canoical_transaction.canonical_event_mapping.fees.first
    fee.amount_cents_as_decimal = 0
    fee.reason = "REVENUE WAIVED"
    fee.save!

    redirect_to transaction_url(params[:id])
  end
end
