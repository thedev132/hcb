# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::FriendlyMemoService::Generate do
  let(:canonical_transaction) { create(:canonical_transaction, memo: "Raw Plaid Transaction 1 Memo") }

  let(:attrs) do
    {
      canonical_transaction: canonical_transaction,
    }
  end

  let(:service) { TransactionEngine::FriendlyMemoService::Generate.new(**attrs) }

  it "returns a result" do
    result = service.run

    expect(result).to eql("RAW PLAID TRANSACTION 1 MEMO")
  end

  context "when memo is blank" do
    before do
      canonical_transaction.memo = " "
      canonical_transaction.save!
    end

    it "returns transfer from bank account" do
      result = service.run

      expect(result).to eql("TRANSFER FROM BANK ACCOUNT")
    end

    context "when amount cents is negative" do
      before do
        canonical_transaction.amount_cents = -100
        canonical_transaction.save!
      end

      it "returns transfer back to bank account" do
        result = service.run

        expect(result).to eql("TRANSFER BACK TO BANK ACCOUNT")
      end
    end

    context "when amount cents is 0" do
      before do
        canonical_transaction.amount_cents = 0
        canonical_transaction.save!
      end

      it "returns nil" do
        result = service.run

        expect(result).to eql(nil)
      end
    end

  end
end
