# frozen_string_literal: true

require "rails_helper"

describe PendingTransactionEngine::CanonicalPendingTransactionService::Import::Donation do

  context "when there is a pending donation transaction ready for processing" do
    it "processes into a CanonicalPendingTransaction" do
      expect(RawPendingDonationTransaction.count).to eq(0)

      raw_pending_donation_transaction = create(:raw_pending_donation_transaction,
                                                date_posted: Date.current)

      expect do
        described_class.new.run
      end.to change { CanonicalPendingTransaction.count }.by(1)
    end
  end

  context "when there are previously processed raw pending donation transactions" do
    let(:raw_pending_donation_transaction) { create(:raw_pending_donation_transaction) }

    before do
      _processed_donation_canonical_pending_transaction = create(:canonical_pending_transaction, raw_pending_donation_transaction:)
    end

    it "ignores it when processing" do
      expect do
        described_class.new.run
      end.to change { CanonicalPendingTransaction.count }.by(0)
    end

    context "when there are also ready to process raw pending donation transactions" do
      it "processes into a CanonicalPendingTransaction" do
        new_donation = create(:raw_pending_donation_transaction,
                              date_posted: Date.current,
                              amount_cents: 1000)

        expect(RawPendingDonationTransaction.count).to eq(2)

        expect do
          described_class.new.run
        end.to change { CanonicalPendingTransaction.count }.by(1)

        pending_transaction = CanonicalPendingTransaction.last
        expect(pending_transaction.raw_pending_donation_transaction_id).to eq(new_donation.id)
        expect(pending_transaction.amount_cents).to eq(new_donation.amount_cents)
      end
    end
  end

end
