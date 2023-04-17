# frozen_string_literal: true

module DonationService
  class Refund
    def initialize(donation_id:)
      @donation_id = donation_id
    end

    def run
      ActiveRecord::Base.transaction do
        # 1. Mark refunded
        donation.mark_refunded!

        # 2. Un-front all pending transaction associated with this donation
        donation.canonical_pending_transactions.update_all(fronted: false)

        raise ArgumentError, "production only" unless Rails.env.production?

        # 3. Process remotely
        ::Partners::Stripe::Refunds::Create.new(payment_intent_id: payment_intent_id).run

        # 4. Create top-up on Stripe. Located in `StripeController#handle_charge_refunded`
      end
    end

    private

    def donation
      @donation ||= ::Donation.find(@donation_id)
    end

    def payment_intent_id
      donation.stripe_payment_intent_id
    end

  end
end
