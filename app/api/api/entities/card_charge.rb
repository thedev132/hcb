# frozen_string_literal: true

module Api
  module Entities

    class CardCharge < LinkedObjectBase
      when_expanded do
        expose :amount_cents, documentation: { type: "integer" }

        format_as_date do
          expose :date
        end

        expose_associated Card, hide: [Card, Organization, User] do |hcb_code, options|
          hcb_code.stripe_card
        end

        expose_associated User do |hcb_code, options|
          hcb_code.stripe_cardholder&.user
        end
      end

    end
  end
end
