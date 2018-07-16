# CreateInvoicePayoutJob is used to queue creation of InvoicePayouts after
# balances become available in Stripe for withdrawal. Please see
# Invoice#queue_payout!.
class CreateInvoicePayoutJob < ApplicationJob
  def perform(invoice)
    invoice.create_payout!
  end
end
