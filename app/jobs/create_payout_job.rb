# CreateInvoicePayoutJob is used to queue creation of InvoicePayouts & DonationPayouts after
# balances become available in Stripe for withdrawal. Please see
# Invoice#queue_payout!.
class CreatePayoutJob < ApplicationJob
  def perform(invoice_or_donation)
    invoice_or_donation.create_payout!
  end
end
