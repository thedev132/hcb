# frozen_string_literal: true

FactoryBot.define do
  factory :login_code do
    association :user
    ip_address { "127.0.0.1" }
  end
end
