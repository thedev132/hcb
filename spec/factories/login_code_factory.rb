# frozen_string_literal: true

FactoryBot.define do
  factory :login_code do
    association :user
  end
end
