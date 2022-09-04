# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_transaction do
    amount_cents { Faker::Number.number(digits: 4) }
    date { Faker::Date.backward(days: 14) }
    memo { Faker::Quote.matz }
    association :hashed_transaction, :plaid
  end
end
