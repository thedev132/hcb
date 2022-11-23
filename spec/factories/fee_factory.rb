# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    association :canonical_event_mapping
    reason { "revenue" }
    amount_cents_as_decimal { Faker::Number.number(digits: 4) }
    event_sponsorship_fee { Faker::Number.number(digits: 4) }
  end
end
