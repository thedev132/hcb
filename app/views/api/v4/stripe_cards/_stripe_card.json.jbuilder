# frozen_string_literal: true

json.created_at stripe_card.created_at
json.id stripe_card.public_id
json.last4 stripe_card.last4 if stripe_card.user == @current_user
json.type stripe_card.card_type
json.status stripe_card.status_text.parameterize(separator: "_")
json.name stripe_card.name

json.total_spent_cents stripe_card.total_spent if local_assigns[:expand]&.include?(:total_spent_cents)

json.organization stripe_card.event, partial: "api/v4/events/event", as: :event if local_assigns[:expand]&.include?(:organization)
json.user         stripe_card.user,  partial: "api/v4/users/user",   as: :user  if local_assigns[:expand]&.include?(:user)
