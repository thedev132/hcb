# frozen_string_literal: true

FactoryBot.define do
  factory :check do
    association :creator, factory: :user
    association :lob_address
    amount { 100 }
    send_date { Time.now + 48.hours }
  end
end
