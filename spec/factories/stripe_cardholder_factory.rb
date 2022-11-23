# frozen_string_literal: true

FactoryBot.define do
  factory :stripe_cardholder do
    association :user
  end
end
