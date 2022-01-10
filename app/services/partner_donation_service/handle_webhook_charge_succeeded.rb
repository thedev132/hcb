# frozen_string_literal: true

module PartnerDonationService
  class HandleWebhookChargeSucceeded
    def initialize(charge)
      @charge = charge
    end

    def run
      return unless partner_donation.unpaid?

      ActiveRecord::Base.transaction do
        partner_donation.mark_pending!
        partner_donation.update_column(:stripe_charge_id, stripe_charge_id)
        partner_donation.update_column(:stripe_charge_created_at, Time.at(@charge.created))
        partner_donation.update_column(:payout_amount_cents, payout_amount_cents)


        # 1. IMPORT. Create raw pending partner donation transaction
        ::RawPendingPartnerDonationTransaction.find_or_initialize_by(partner_donation_transaction_id: partner_donation.id.to_s).tap do |t|
          t.amount_cents = payout_amount_cents
          t.date_posted = Time.at(@charge.created)
        end.save!

        rppdt = ::RawPendingPartnerDonationTransaction.find_by(partner_donation_transaction_id: partner_donation.id.to_s)


        # 2. CANONIZE. Create CanonicalPendingTransaction if it doesn't already exist
        return if ::CanonicalPendingTransaction.where(raw_pending_partner_donation_transaction_id: rppdt.id).any?

        cpt = ::CanonicalPendingTransaction.create!(
          date: rppdt.date,
          memo: rppdt.memo,
          amount_cents: rppdt.amount_cents,
          raw_pending_partner_donation_transaction_id: rppdt.id
        )

        # 3. MAP TO EVENT
        return unless cpt.raw_pending_partner_donation_transaction.likely_event_id

        CanonicalPendingEventMapping.create!(
          event_id: cpt.raw_pending_partner_donation_transaction.likely_event_id,
          canonical_pending_transaction_id: cpt.id
        )
      end
    end

    private

    def hcb_metadata_identifier
      @charge[:metadata][:hcb_metadata_identifier]
    end

    def stripe_charge_id
      @charge.id
    end

    def partner_donation
      PartnerDonation.find_by_public_id(hcb_metadata_identifier)
    end

    def payout_amount_cents
      @expanded_charge ||= ::Partners::Stripe::Charges::Show.new(stripe_api_key: partner_donation.event.partner.stripe_api_key, id: stripe_charge_id).run

      @expanded_charge.balance_transaction["net"].to_i # use net (after fee)
    end

    def partner_id
      partner_donation.event.partner.id
    end

  end
end
