# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalPendingTransactionService::Settle do
  let(:canonical_pending_transaction) { create(:canonical_pending_transaction) }
  let(:canonical_transaction) { create(:canonical_transaction) }

  let(:service) {
    CanonicalPendingTransactionService::Settle.new(
      canonical_transaction: canonical_transaction,
      canonical_pending_transaction: canonical_pending_transaction
    )
  }

  it "creates a canonical_pending_settled_mapping" do
    service.run!

    canonical_transaction.reload
    canonical_pending_transaction.reload

    canonical_pending_settled_mapping = CanonicalPendingSettledMapping.last
    expect(canonical_transaction.canonical_pending_settled_mapping).to eq(canonical_pending_settled_mapping)
    expect(canonical_pending_transaction.canonical_pending_settled_mappings).to eq([canonical_pending_settled_mapping])
  end

  context "when canonical_pending_transaction has a custom_memo" do
    let(:canonical_pending_transaction) { create(:canonical_pending_transaction, custom_memo: "I am a custom memo") }

    context "when canonical_transaction custom_memo is nil" do
      let(:canonical_transaction) { create(:canonical_transaction, custom_memo: nil) }

      it "should copy the custom_memo from the pending transaction" do
        service.run!

        expect(canonical_transaction.reload.custom_memo).to eq(canonical_pending_transaction.custom_memo)
      end
    end

    context "when canonical_transaction has a custom_memo" do
      let(:canonical_transaction) { create(:canonical_transaction, custom_memo: "I am a different custom memo") }

      it "should keep the canonical_transaction's custom_memo" do
        initial_custom_memo = canonical_transaction.custom_memo

        service.run!

        expect(canonical_transaction.reload.custom_memo).to eq(initial_custom_memo)
        expect(canonical_transaction.custom_memo).to_not eq(canonical_pending_transaction.custom_memo)
      end
    end
  end
end
