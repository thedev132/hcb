# frozen_string_literal: true

FactoryBot.define do
  factory :raw_pending_outgoing_ach_transaction do
    amount_cents { 50 }
  end
end
