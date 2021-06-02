module PartnerDonationService
  class CreateRemotePayout
    def initialize(stripe_charge_id:)
      @stripe_charge_id = stripe_charge_id
    end

    def run
      raise ArgumentError, "must be paid" unless stripe_charge.paid?
      raise ArgumentError, "must belong to a partner donation" unless partner_donation
      raise ArgumentError, "must be a partner donation in pending status" unless partner_donation.pending?

      ActiveRecord::Base.transaction do
        partner_donation.mark_in_transit!
        partner_donation.update_column(:payout_amount_cents, amount_cents)

        ::Partners::Stripe::Payouts::Create.new(attrs).run
      end
    end

    private

    def attrs
      {
        amount_cents: amount_cents,
        statement_descriptor: statement_descriptor,
        metdata: {
          donationIdentifier: donation_identifier
        }
      }
    end

    def stripe_charge
      @stripe_charge ||= ::Partners::Stripe::Charges::Show.new(id: @stripe_charge_id).run
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
      @partner_donation ||= ::PartnerDonation.find_by!(donation_identifier: donation_identifier)
    end

    def metadata
      @metadata ||= stripe_charge.metadata
    end

    def donation_identifier
      metadata["donationIdentifier"]
    end
  end
end
