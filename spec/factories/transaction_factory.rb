# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    association :bank_account
    amount { Faker::Number.number(digits: 4) }
    sequence(:plaid_id) { |n| n }
  end
end
