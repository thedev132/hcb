# frozen_string_literal: true



FactoryBot.define do
  factory :hcb_code do
    transient do
      code_type { ::TransactionGroupingEngine::Calculate::HcbCode::INVOICE_CODE }
    end

    sequence(:hcb_code) { |n| "HCB-#{code_type}-#{n}" }
  end
end
