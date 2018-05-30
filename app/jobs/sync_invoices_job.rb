class SyncInvoicesJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      Invoice.find_each do |i|
        inv = StripeService::Invoice.retrieve(i.stripe_invoice_id)

        i.set_fields_from_stripe_invoice(inv)

        i.save!
      end
    end

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end
end
