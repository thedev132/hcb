# frozen_string_literal: true

json.array! @stripe_cards, partial: "api/v4/stripe_cards/stripe_card", as: :stripe_card
