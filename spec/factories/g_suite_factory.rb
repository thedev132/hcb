# frozen_string_literal: true

FactoryBot.define do
  factory :g_suite do
    association :event
    domain { Faker::Internet.domain_name }
  end
end
