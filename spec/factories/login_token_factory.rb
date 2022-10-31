# frozen_string_literal: true

FactoryBot.define do
  factory :login_token do
    association :user
    expiration_at { Faker::Date.forward(days: 14) }
    token { "tok_#{SecureRandom.alphanumeric(32)}" }
  end
end
