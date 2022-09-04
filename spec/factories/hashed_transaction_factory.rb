# frozen_string_literal: true

FactoryBot.define do
  factory :hashed_transaction do
    trait :plaid do
      association :raw_plaid_transaction
    end
  end
end
