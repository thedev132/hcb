# frozen_string_literal: true

FactoryBot.define do
  factory :ach_transfer do
    amount { 50 }
    routing_number { Faker::Number.number(digits: 9) }
    account_number { Faker::Number.number(digits: 10) }
  end
end
