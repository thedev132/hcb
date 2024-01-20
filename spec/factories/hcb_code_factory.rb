# frozen_string_literal: true

FactoryBot.define do
  factory :hcb_code do
    sequence(:hcb_code) { |n| "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE}-#{n}" }
  end
end
