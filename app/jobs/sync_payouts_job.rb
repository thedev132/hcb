# frozen_string_literal: true

class SyncPayoutsJob < ApplicationJob

  def perform
    ActiveRecord::Base.transaction do
      InvoicePayout.find_each(batch_size: 100) do |p|
        payout = StripeService::Payout.retrieve(p.stripe_payout_id)
        p.set_fields_from_stripe_payout(payout)
        p.save!
      end

      DonationPayout.find_each(batch_size: 100) do |p|
        payout = StripeService::Payout.retrieve(p.stripe_payout_id)
        p.set_fields_from_stripe_payout(payout)
        p.save!
      end
    end
  end
end
