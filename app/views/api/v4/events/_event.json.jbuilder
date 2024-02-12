# frozen_string_literal: true

json.created_at event.created_at
json.id event.public_id
json.name event.name
json.country event.country
json.slug event.slug
json.icon event.logo.attached? ? Rails.application.routes.url_helpers.url_for(event.logo) : nil
json.playground_mode event.demo_mode?
json.playground_mode_meeting_requested event.demo_mode_request_meeting_at.present?
json.transparent event.is_public?
json.fee_percentage event.sponsorship_fee.to_f
json.category event.category&.parameterize(separator: "_")

if local_assigns[:expand]&.include?(:balance_cents)
  json.balance_cents event.balance_available_v2_cents
  json.fee_balance_cents event.fronted_fee_balance_v2_cents
end

if policy(event).account_number? && local_assigns[:expand]&.include?(:account_number)
  json.account_number event.account_number
  json.routing_number event.routing_number
  json.swift_bic_code event.bic_code
end

json.users event.users, partial: "api/v4/users/user", as: :user if local_assigns[:expand]&.include?(:users)
