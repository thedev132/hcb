# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::Name.unique.name }
    association :partner
    sponsorship_fee { 0 }
    organization_identifier { SecureRandom.hex(30) + Faker::Name.unique.name }

    trait :demo_mode do
      demo_mode { true }
    end
  end
end
