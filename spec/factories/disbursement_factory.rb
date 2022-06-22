# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    association :event
    association :source_event, factory: :event
    amount { Faker::Number.positive.to_i }
    name { Faker::Name.unique.name }
  end
end
