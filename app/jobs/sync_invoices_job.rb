class SyncInvoicesJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    Invoice.find_each do |i|
      i.transaction do
        was_paid = i.paid

        inv = StripeService::Invoice.retrieve(i.stripe_invoice_id)
        i.set_fields_from_stripe_invoice(inv)
        i.save!

        now_paid = i.paid

        if !was_paid && now_paid
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

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end
end
