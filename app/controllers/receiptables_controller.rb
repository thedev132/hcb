# frozen_string_literal: true

class ReceiptablesController < ApplicationController
  before_action :set_receiptable
  skip_after_action :verify_authorized # do not force pundit

  def mark_no_or_lost
    if @receiptable.no_or_lost_receipt!
      flash[:success] = "Marked no/lost receipt on that transaction."
      redirect_to @receiptable
    else
      flash[:error] = "Failed to mark that transaction as no/lost receipt."
      redirect_back(fallback_location: @receiptable)
    end
  end

  private

  def set_receiptable
    @klass = params[:receiptable_type].camelize.constantize
    # raise ArgumentError, "Class is not receiptable" unless @klass.included_modules.include?(Receiptable)?
    @receiptable = @klass.find(params[:receiptable_id])
  end
end
