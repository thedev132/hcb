# frozen_string_literal: true

FactoryBot.define do
  factory :donation do
    association :event
    name { Faker::Name.unique.name }
    email { Faker::Internet.email }
    amount { Faker::Number.number(digits: 4) }
  end
end
