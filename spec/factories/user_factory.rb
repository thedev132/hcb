# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }

    trait :make_admin do
      access_level { :admin }
    end
  end
end
