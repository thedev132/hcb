# frozen_string_literal: true

module Api
  module Entities
    class AchTransfer < LinkedObjectBase
      when_expanded do
        expose :amount, as: :amount_cents
        expose :created_at, as: :date
        expose :aasm_state, as: :status, documentation: {
          values: %w[
            pending
            in_transit
            deposited
            rejected
          ]
        }
        expose :beneficiary do
          expose :recipient_name, as: :name
        end
      end

      def self.entity_name
        "ACH Transfer" # this overrides the `entity_name` method defined by the Base class
      end

    end
  end
end
