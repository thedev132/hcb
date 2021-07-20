# frozen_string_literal: true

module PartnerDonationService
  class Import
    def initialize(partner_id:)
      @partner_id = partner_id
    end

    def run
      ::Partners::Stripe::Charges::List.new(list_attrs).run do |sc|
        next if already_processed?(sc)

        ::PartnerDonationJob::CreateRemotePayout.perform_later(partner.id, sc.id)
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

    def already_processed?(sc)
      ::PartnerDonation.where(stripe_charge_id: sc.id).exists?
    end
  end
end
