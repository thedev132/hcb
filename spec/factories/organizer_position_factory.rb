# frozen_string_literal: true

FactoryBot.define do
  factory :organizer_position do
    association :user
    association :event
  end
end
