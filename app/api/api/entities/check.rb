# frozen_string_literal: true

module Api
  module Entities
    class Check < LinkedObjectBase
      when_expanded do
        expose :amount, as: :amount_cents, documentation: { type: "integer" }
        expose :created_at, as: :date
        expose :aasm_state, as: :status, documentation: {
          values: %w[
            scheduled
            in_transit
            in_transit_and_processed
            deposited
            canceled
            voided
            refunded
          ]
        }
      end

    end
  end
end
