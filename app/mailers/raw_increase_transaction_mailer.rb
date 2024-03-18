# frozen_string_literal: true

class RawIncreaseTransactionMailer < ApplicationMailer
  def deprecated_account_number
    @transaction = params[:transaction]
    @amount = @transaction.amount_cents
    @event = @transaction.event

    mail to: @event.users.map(&:email_address_with_name), subject: "[ACTION REQUIRED] Your HCB account number has changed"
  end

end
