# frozen_string_literal: true

FactoryBot.define do
  factory :organizer_position_invite do
    association :event
    email { Faker::Internet.email }
    association :sender, factory: :user
    association :user
  end
end
