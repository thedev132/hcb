# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::Name.unique.name }
    sponsorship_fee { 0 }
    organization_identifier { SecureRandom.hex(30) }

    trait :partnered do
      association :partner
    end

    trait :demo_mode do
      demo_mode { true }
    end

    trait :card_grant_event do
      association :card_grant_setting
    end
  end
end
