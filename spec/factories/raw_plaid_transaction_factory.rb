# frozen_string_literal: true

FactoryBot.define do
  factory :raw_plaid_transaction do
    amount_cents { Faker::Number.number(digits: 4) }
    unique_bank_identifier { "FSMAIN" }
    plaid_transaction { { "name": Faker::Quote.matz } }
  end
end
