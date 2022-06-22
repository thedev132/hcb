# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    slug { Faker::Name.unique.name }
  end
end
