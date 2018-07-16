class SyncInvoicePayoutsJob < ApplicationJob
  RUN_EVERY = 1.hour

  def perform(repeat = false)
    ActiveRecord::Base.transaction do
      InvoicePayout.find_each do |p|
        payout = StripeService::Payout.retrieve(p.stripe_payout_id)
        p.set_fields_from_stripe_payout(payout)
        p.save!
      end
    end

    if repeat
      self.class.set(wait: RUN_EVERY).perform_later(true)
    end
  end
end
