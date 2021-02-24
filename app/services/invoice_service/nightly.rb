# frozen_string_literal: true

module InvoiceService
  class Nightly
    def run
      # 1. iterate over open invoices
      Invoice.open.each do |i|

        # 2. grab remote invoice
        remote_invoice = ::Partners::Stripe::Invoices::Show.new(id: i.stripe_invoice_id).run

        # 3. update invoice field values
        i.set_fields_from_stripe_invoice(remote_invoice)
        i.save!

        # 4. queue payout
        i.queue_payout! if i.reload.paid? # now is paid
      end
    end
  end
end
