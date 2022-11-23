# frozen_string_literal: true

FactoryBot.define do
  factory :stripe_card do
    association :event
    association :stripe_cardholder

    trait :with_stripe_id do
      sequence(:stripe_id) { |n| "ic_#{n}" }
      stripe_brand { "Visa" }
      stripe_exp_month { "2" }
      stripe_exp_year { "2030" }
      last4 { "9876" }
      stripe_status { "active" }
    end
  end
end
