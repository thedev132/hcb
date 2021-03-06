# frozen_string_literal: true

module DonationService
  class Queue
    def initialize(donation_id:)
      @donation_id = donation_id
    end

    def run
      raise NoAssociatedStripeCharge if remote_payment_intent.charges.nil?

      # get the balance transaction of the first (and only) charge
      b_tnx = remote_payment_intent.charges.data.first.balance_transaction

      funds_available_at = Util.unixtime(b_tnx.available_on)
      create_payout_at = funds_available_at + 1.day

      donation.payout_creation_queued_at = DateTime.current
      donation.payout_creation_queued_for = create_payout_at
      donation.payout_creation_balance_net = b_tnx.net # amount to pay out
      donation.payout_creation_balance_stripe_fee = b_tnx.fee
      donation.payout_creation_balance_available_at = funds_available_at

      donation.save!
    end

    private

    def donation
      @donation ||= Donation.find(@donation_id)
    end

    def remote_payment_intent
      @remote_payment_intent ||= ::Partners::Stripe::PaymentIntents::Show.new(id: donation.stripe_payment_intent_id).run
    end
  end
end
