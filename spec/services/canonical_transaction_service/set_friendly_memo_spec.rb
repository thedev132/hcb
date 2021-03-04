# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalTransactionService::SetFriendlyMemo, type: :model do
  fixtures  "canonical_transactions"
  
  let(:canonical_transaction) { canonical_transactions(:canonical_transaction1) }
  let(:friendly_memo) { "Friendly Memo" }

  let(:attrs) do
    {
      canonical_transaction_id: canonical_transaction.id,
      friendly_memo: friendly_memo
    }
  end

  let(:service) { CanonicalTransactionService::SetFriendlyMemo.new(attrs) }

  it "sets friendly memo" do
    service.run

    expect(canonical_transaction.reload.friendly_memo).to eql(friendly_memo)
  end

  context "friendly memo is empty string" do
    let(:friendly_memo) { " " }

    it "raises error if friendly memo is blank" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "friendly memo is nil" do
    let(:friendly_memo) { nil }

    it "sets friendly memo" do
      service.run

      expect(canonical_transaction.reload.friendly_memo).to eql(nil)
    end
  end
end
