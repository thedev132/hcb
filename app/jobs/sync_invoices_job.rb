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
          i.queue_payout!
        end
      end
    end

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end
end
