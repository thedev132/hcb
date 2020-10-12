class SyncInvoicesJob < ApplicationJob
  def perform
    Invoice.find_each do |i|
      if i.livemode && !Rails.env.production?
        puts "(Development) Skipping invoice ##{i.id}: accessing production invoices with development keys will fail"
        next
      end

      i.transaction do
        was_paid = i.paid?

        inv = StripeService::Invoice.retrieve({
          id: i.stripe_invoice_id,
          expand: ['charge.payment_method_details']
        })
        i.set_fields_from_stripe_invoice(inv)
        i.save!

        now_paid = i.paid?

        if !was_paid && now_paid
          begin
            logger.debug("Queueing payout for invoice: #{i.attributes.inspect}}")
            i.queue_payout!

          # This happens in the case where the invoice was for such a low amount,
          # like $0.10, that Stripe didn't bother creating a charge and instead
          # credited a balance to the invoice. See in_1CppXuFSaumjmb9rrEUviPYy
          # in live mode for an example.
          rescue Invoice::NoAssociatedStripeCharge
            logger.debug("Payout aborted due to no associated Stripe charge existing")
          end
        end
      end
    end
  end
end
