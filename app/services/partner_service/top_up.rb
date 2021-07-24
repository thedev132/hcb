# frozen_string_literal: true

module PartnerService
  class TopUp
    def initialize(partner_id:, amount_cents:)
      @partner_id = partner_id
      @amount_cents = amount_cents
    end

    def run
      ::Partners::Stripe::Topup::Create.new(attrs).run
    end

    private

    def attrs
      {
        stripe_api_key: stripe_api_key,
        amount_cents: @amount_cents,
        statement_descriptor: statement_descriptor
      }
    end

    def stripe_api_key
      partner.stripe_api_key
    end

    def statement_descriptor
      "Stripe Top-up #{partner.id}"
    end

    def partner
      @partner ||= Partner.find(@partner_id)
    end
  end
end
