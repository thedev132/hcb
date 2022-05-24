# frozen_string_literal: true

class MoneyReceivedMailerPreview < ActionMailer::Preview
  def money_received
    @transaction = InvoicePayout.first.t_transaction
    MoneyReceivedMailer.with(transaction: @transaction).money_received
  end

end
