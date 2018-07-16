class CreateInvoicePayoutJob < ApplicationJob
  def perform(invoice)
    invoice.create_payout!
  end
end
