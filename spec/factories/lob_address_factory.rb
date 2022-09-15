# frozen_string_literal: true

FactoryBot.define do
  factory :lob_address do
    association :event
    name { Faker::Name.name }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
  end
end
