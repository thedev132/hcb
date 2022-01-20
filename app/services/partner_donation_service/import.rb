# frozen_string_literal: true

module PartnerDonationService
  class Import
    def initialize(partner_id:)
      @partner_id = partner_id
    end

    def run
      return unless partner.stripe_api_key.present? && partner.stripe_api_key.start_with?("sk_live_")

      ::Partners::Stripe::Charges::List.new(list_attrs).run do |sc|
        pdn = partner_donation(sc)

        # All Charges on Partner Stripe accounts should be associated with a
        # PartnerDonation. If we can't find one, report and move on.
        unless pdn
          Airbrake.notify(
            "Stripe charge #{sc.id} has no partner donation associated with it."\
            "The HCB Metadata Identifier is #{hcb_metadata_identifier(sc) || "missing!"}"
          )
          next
        end

        # This PDN now has a Stripe Charge — meaning that it has been paid.
        # If the current state of the PDN is "unpaid", then let's transition it
        # to "pending" (paid, but not payout yet).
        if pdn.unpaid?
          ActiveRecord::Base.transaction do
            pdn.mark_pending!
            pdn.update_column(:stripe_charge_id, sc.id)
            pdn.update_column(:stripe_charge_created_at, Time.at(sc.created))
            pdn.update_column(:payout_amount_cents, payout_amount_cents(sc))
          end
        end

        # If the PDN has been paid, let's create a payout on Stripe.
        #
        # Since we are not waiting until the funds from this stripe charge are
        # available, there is a chance this may error. That should be okay since
        # the payout will be created by this job once there are sufficient funds.
        if pdn.pending?
          ::PartnerDonationJob::CreateRemotePayout.perform_later(partner.id, sc.id)
        end
      end
    end

    private

    def list_attrs
      {
        stripe_api_key: partner.stripe_api_key,
        start_date: Time.now.utc - 100.days
      }
    end

    def partner
      @partner ||= ::Partner.find(@partner_id)
    end

    def partner_donation(sc)
      PartnerDonation.find_by_public_id(hcb_metadata_identifier(sc))
    end

    def payout_amount_cents(sc)
      @expanded_charge ||= ::Partners::Stripe::Charges::Show.new(stripe_api_key: partner_donation(sc).event.partner.stripe_api_key, id: sc.id).run

      @expanded_charge.balance_transaction["net"].to_i # use net (after fee)
    end

    def hcb_metadata_identifier(sc)
      sc.payment_intent.metadata["hcb_metadata_identifier"]
    end

  end
end
