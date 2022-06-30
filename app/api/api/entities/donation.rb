# frozen_string_literal: true

module Api
  module Entities
    class Donation < LinkedObjectBase
      when_expanded do
        expose :amount, as: :amount_cents, documentation: { type: "integer" }
        expose :donor do
          expose :name
        end
        with_options(format_with: :iso_timestamp) do
          expose :created_at, as: :date
        end
        expose :aasm_state, as: :status, documentation: {
          values: %w[
            pending
            in_transit
            deposited
            failed
            refunded
          ]
        }

      end

    end
  end
end
