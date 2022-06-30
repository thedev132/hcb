# frozen_string_literal: true

module Api
  module Entities
    class Invoice < LinkedObjectBase
      when_expanded do
        expose :item_amount, as: :amount_cents
        expose :sponsor do
          expose :id do |invoice, options|
            invoice.sponsor.public_id
          end
          expose :name do |invoice, options|
            invoice.sponsor.name
          end
        end
        with_options(format_with: :iso_timestamp) do
          expose :created_at, as: :date
        end
        expose :status, documentation: {
          values: %w[
            open
            paid
            void
          ]
        } do |invoice, options|
          invoice.aasm_state.split('_').first # remove the "_v2" suffix
        end

      end

    end
  end
end
