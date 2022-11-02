# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }

    trait :make_admin do
      admin_at { Time.zone.now }
    end
  end
end
