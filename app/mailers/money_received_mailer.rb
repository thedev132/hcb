# frozen_string_literal: true

class MoneyReceivedMailer < ApplicationMailer
  def money_received
    @transaction = params[:transaction]
    @emails = @transaction.event.users.pluck(:email)

    mail to: @emails, subject: "Money from #{@transaction.invoice_payout.invoice.sponsor.name} is in your Hack Club Bank account 💵"
  end
end
