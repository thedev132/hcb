# frozen_string_literal: true

FactoryBot.define do
  factory :raw_csv_transaction do
    amount_cents { Faker::Number.number(digits: 4) }
    unique_bank_identifier { "FSMAIN" }
    memo { Faker::Quote.matz }
    date_posted { Faker::Date.backward(days: 14) }
  end
end
