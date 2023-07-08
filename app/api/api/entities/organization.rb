# frozen_string_literal: true

module Api
  module Entities
    class Organization < Base
      when_expanded do
        expose :name
        expose :slug
        expose :category, documentation: {
          values: %w[
            hackathon
            high_school_hackathon
            event
            hack_club
            nonprofit
            robotics_team
            hardware_grant
            hack_club_hq
          ]
        } do |organization|
          organization.category&.parameterize&.underscore
        end
        expose :is_public, as: :transparent, documentation: { type: "boolean" }
        expose :demo_mode, documentation: { type: "boolean" }
        expose :logo do |organization|
          organization.logo.attached? ? Rails.application.routes.url_helpers.url_for(organization.logo) : nil
        end
        expose :donation_header do |organization|
          organization.donation_header_image.attached? ? Rails.application.routes.url_helpers.url_for(organization.donation_header_image) : nil
        end
        expose :public_message do |event|
          event.public_message.presence
        end
        expose :balances do
          expose :balance_available_v2_cents, as: :balance_cents, documentation: { type: "integer" }
          expose :fee_balance_v2_cents, as: :fee_balance_cents, documentation: { type: "integer" }
          expose :pending_incoming_balance_v2_cents, as: :incoming_balance_cents, documentation: { type: "integer" }
          expose :total_raised, as: :total_raised, documentation: { type: "integer" }
        end

        format_as_date do
          expose :created_at
        end

        # This association is intentionally nested within the `when_expanded`.
        # This means that users will only be visible when an Organization is
        # expanded.
        expose_associated User, as: "users", documentation: { type: User, is_array: true } do |event, options|
          event.users
        end
      end

    end
  end
end
