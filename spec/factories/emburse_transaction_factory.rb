# frozen_string_literal: true

FactoryBot.define do
  factory :emburse_transaction do
    amount { Faker::Number.number(digits: 4) }
  end
end
