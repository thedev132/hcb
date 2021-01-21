require 'csv'

class CanonicalTransactionsController < ApplicationController
  def show
    authorize CanonicalTransaction

    redirect_to transaction_url(params[:id])
  end
end
