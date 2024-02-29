# frozen_string_literal: true

require "rails_helper"

OUTGOING_BANK_FEE_MEMO = "HACK CLUB BANK FEE"

describe HcbCodeService::SuggestedMemos do

  context "when a bank fee transaction is passed" do
    let(:event) { create(:event) }

    it "returns all memo suggestions for similar bank fee transactions" do
      3.times { create_bank_fee_transaction }

      new_transaction = create_bank_fee_transaction(custom_memo: OUTGOING_BANK_FEE_MEMO)
      result = described_class.new(hcb_code: new_transaction.local_hcb_code, event:).run

      expect(result.length).to eq(3)
      expect(result).to all(match(/#{OUTGOING_BANK_FEE_MEMO} \d{6}/))
    end

    def create_bank_fee_transaction(custom_memo: nil)
      amount = Faker::Number.number(digits: 4)
      bank_fee = create(:bank_fee, amount_cents: amount, event:)

      memo = OUTGOING_BANK_FEE_MEMO
      custom_memo ||= "#{OUTGOING_BANK_FEE_MEMO} #{Faker::Number.number(digits: 6)}"

      create(:canonical_transaction, amount_cents: amount, event:, memo:, custom_memo:, transaction_source: bank_fee)
    end

  end
end
