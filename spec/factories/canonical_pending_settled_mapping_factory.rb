# frozen_string_literal: true

FactoryBot.define do
  factory :canonical_pending_settled_mapping do
    association :canonical_pending_transaction
    association :canonical_transaction
  end
end
