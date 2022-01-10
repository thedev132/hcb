# frozen_string_literal: true

module PartnerDonationService
  class Import
    def initialize(partner_id:)
      @partner_id = partner_id
    end

    def run
      ::Partners::Stripe::Charges::List.new(list_attrs).run do |sc|
        next unless partner_donation?(sc)

        if partner_donation(sc).unpaid?
          ActiveRecord::Base.transaction do
            partner_donation(sc).mark_pending!
            partner_donation(sc).update_column(:stripe_charge_id, sc.id)
            partner_donation(sc).update_column(:stripe_charge_created_at, Time.at(sc.created))
            partner_donation(sc).update_column(:payout_amount_cents, payout_amount_cents(sc))
          end
        end

        if partner_donation(sc).pending?
          ::PartnerDonationJob::CreateRemotePayout.perform_later(partner.id, sc.id)
        end
      end

      true
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

    def partner_donation?(public_id)
      !partner_donation(public_id).nil?
    end

    def partner_donation(sc)
      PartnerDonation.find_by_public_id(hcb_metadata_identifier(sc))
    end

    def payout_amount_cents(sc)
      @expanded_charge ||= ::Partners::Stripe::Charges::Show.new(stripe_api_key: partner_donation(sc).event.partner.stripe_api_key, id: sc.id).run

      @expanded_charge.balance_transaction["net"].to_i # use net (after fee)
    end

    def hcb_metadata_identifier(sc)
      sc.metadata["hcb_metadata_identifier"]
    end

  end
end
