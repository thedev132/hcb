# frozen_string_literal: true

module Api
  module Entities
    class Organization < Base
      when_expanded do
        expose :name
        expose :slug
        expose :is_public, as: :transparent, documentation: { type: "boolean" }
        expose :balances do
          expose :balance_v2_cents, as: :balance_cents, documentation: { type: "integer" }
          expose :fee_balance_v2_cents, as: :fee_balance_cents, documentation: { type: "integer" }
          expose :pending_incoming_balance_v2_cents, as: :incoming_balance_cents, documentation: { type: "integer" }
        end

        with_options(format_with: :iso_timestamp) do
          expose :created_at
        end
      end

      when_showing(User) do
        expose :users, documentation: { is_array: true, type: User } do |org, options|
          User.represent(org.users, options_hide(self))
        end
      end

    end
  end
end
