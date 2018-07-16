class SyncInvoicesJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      needs_payout_queued = []

      Invoice.find_each do |i|
        was_paid = i.paid

        inv = StripeService::Invoice.retrieve(i.stripe_invoice_id)
        i.set_fields_from_stripe_invoice(inv)
        i.save!

        now_paid = i.paid

        needs_payout_queued << i if !was_paid && now_paid
      end

      needs_payout_queued.each do |i|
        i.queue_payout!
      end
    end

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end
end
