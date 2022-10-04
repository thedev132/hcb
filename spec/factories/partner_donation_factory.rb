# frozen_string_literal: true

FactoryBot.define do
  factory :partner_donation do
    association :event
  end
end
