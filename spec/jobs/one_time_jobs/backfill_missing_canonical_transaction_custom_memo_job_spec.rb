# frozen_string_literal: true

require "rails_helper"

RSpec.describe OneTimeJobs::BackfillMissingCanonicalTransactionCustomMemoJob, type: :model do
  let(:service) { described_class.new }

  context "when a canonical_transaction's custom_memo is nil" do
    let(:canonical_transaction) { create(:canonical_transaction, custom_memo: nil, canonical_pending_transaction: canonical_pending_transaction) }

    context "when the associated canonical_pending_transaction's custom_memo is present" do
      let(:canonical_pending_transaction) { create(:canonical_pending_transaction, custom_memo: "I should be copied to the canonical_transaction") }

      it "copies the custom_memo from the canonical_pending_transaction" do
        canonical_transaction

        service.perform
        expect(canonical_transaction.reload.custom_memo).to be_present
        expect(canonical_transaction.custom_memo).to eq(canonical_pending_transaction.custom_memo)
      end
    end

    context "when the associated canonical_pending_transaction's custom_memo is nil" do
      let(:canonical_pending_transaction) { create(:canonical_pending_transaction, custom_memo: nil) }

      it "leaves the canonical_transaction custom_memo as nil" do
        canonical_transaction

        service.perform
        expect(canonical_transaction.reload.custom_memo).to be_nil
      end
    end
  end

  context "when a canonical_transaction's custom_memo is present" do
    let(:existing_custom_memo) { "I have my own custom memo" }
    let(:canonical_transaction) { create(:canonical_transaction, custom_memo: existing_custom_memo, canonical_pending_transaction: canonical_pending_transaction) }

    context "when the associated canonical_pending_transaction's custom_memo is present and different" do
      let(:canonical_pending_transaction) { create(:canonical_pending_transaction, custom_memo: "I am a different custom memo") }

      it "leaves the canonical_transaction custom_memo as is" do
        canonical_transaction

        service.perform
        expect(canonical_transaction.reload.custom_memo).to eq(existing_custom_memo)
        expect(canonical_transaction.custom_memo).to_not eq(canonical_pending_transaction.custom_memo)
      end
    end

    context "when the associated canonical_pending_transaction's custom_memo is nil" do
      let(:canonical_pending_transaction) { create(:canonical_pending_transaction, custom_memo: nil) }

      it "leaves the canonical_transaction custom_memo as is" do
        canonical_transaction

        service.perform
        expect(canonical_transaction.reload.custom_memo).to eq(existing_custom_memo)
        expect(canonical_transaction.custom_memo).to_not eq(canonical_pending_transaction.custom_memo)
      end
    end
  end
end
