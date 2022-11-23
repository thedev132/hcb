# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor do
    association :event
    name { Faker::Name.name }
    contact_email { Faker::Internet.email }
    address_line1 { Faker::Address.street_address }
    address_city { Faker::Address.city }
    address_state { Faker::Address.state_abbr }
    address_postal_code { Faker::Address.zip }
  end
end
