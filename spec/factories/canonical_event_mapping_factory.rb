# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_event_mapping do
    association :canonical_transaction
    association :event
  end
end
