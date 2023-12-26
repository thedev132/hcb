# frozen_string_literal: true

class RawIncreaseTransactionMailer < ApplicationMailer
  def deprecated_account_number
    @transaction = params[:transaction]
    @event = @transaction.event

    mail to: @event.users.pluck(:email), subject: "[ACTION REQUIRED] Your HCB account number has changed"
  end

end
