# frozen_string_literal: true

json.created_at event.created_at
json.id event.public_id
json.name event.name
json.country event.country
json.slug event.slug
json.icon event.logo.attached? ? Rails.application.routes.url_helpers.url_for(event.logo) : nil
json.playground_mode event.demo_mode?
json.transparent event.is_public?
json.fee_percentage event.sponsorship_fee.to_f
json.category event.category&.parameterize(separator: "_")

if local_assigns[:expanded]
  json.balance_cents event.balance_available_v2_cents
end
