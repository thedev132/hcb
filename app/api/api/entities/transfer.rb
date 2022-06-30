# frozen_string_literal: true

module Api
  module Entities
    class Transfer < LinkedObjectBase
      when_expanded do
        expose :amount, as: :amount_cents
        expose :created_at, as: :date
        expose :v3_api_state, as: :status, documentation: {
          values: %w[
            fulfilled
            processing
            rejected
            errored
            under_review
            pending
          ]
        }

      end

    end
  end
end
