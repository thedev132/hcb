# frozen_string_literal: true

module PartnerService
  class TopUp
    def initialize(partne_id:, amount_cents:)
      @partner_id = partner_id
      @amount_cents = amount_cents
    end

    def run
      ::PartnerService::Topup::Create.new(attrs).run
    end

    private

    def attrs
      {
        stripe_api_key: stripe_api_key,
        amount_cents: @amount_cents,
        statement_description: statement_description
      }
    end

    def stripe_api_key
      partner.stripe_api_key
    end

    def statement_description
      "Stripe Top-up #{partner.id}"
    end

    def partner
      @partner ||= Partner.find(@partner_id)
    end
  end
end
