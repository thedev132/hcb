# frozen_string_literal: true

module PartnerDonationService
  class CreateRemotePayout
    def initialize(partner_id:, stripe_charge_id:)
      @partner_id = partner_id
      @stripe_charge_id = stripe_charge_id
    end

    def run
      raise ArgumentError, "must be paid" unless stripe_charge.paid?
      raise ArgumentError, "must belong to a partner donation" unless partner_donation
      raise ArgumentError, "must be a partner donation in pending status" unless partner_donation.pending?

      ActiveRecord::Base.transaction do
        partner_donation.mark_in_transit!

        ::Partners::Stripe::Payouts::Create.new(
          stripe_api_key: partner.stripe_api_key,
          amount_cents:,
          statement_descriptor:,
          hcb_metadata_identifier:
        ).run
      end
    end

    private

    def stripe_charge
      @stripe_charge ||= ::Partners::Stripe::Charges::Show.new(stripe_api_key: partner.stripe_api_key, id: @stripe_charge_id).run
    end

    def amount_cents
      @amount_cents ||= stripe_charge.balance_transaction["net"] # use net (after fee)
    end

    def statement_descriptor
      "HCB-#{short_code}"
    end

    def short_code
      partner_donation.local_hcb_code.short_code
    end

    def partner_donation
      @partner_donation ||= ::PartnerDonation.find_by_public_id(hcb_metadata_identifier)
    end

    def partner
      @partner ||= ::Partner.find(@partner_id)
    end

    def metadata
      @metadata ||= stripe_charge.payment_intent.metadata
    end

    def hcb_metadata_identifier
      metadata["hcb_metadata_identifier"]
    end

  end
end
