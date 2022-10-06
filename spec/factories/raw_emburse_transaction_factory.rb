# frozen_string_literal: true

FactoryBot.define do
  factory :raw_emburse_transaction do
    amount_cents { Faker::Number.number(digits: 4) }
    unique_bank_identifier { "EMBURSEISSUING1" }
    emburse_transaction { {} }
  end
end
