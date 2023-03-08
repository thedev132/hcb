# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::CanonicalTransactionService::Import::EmburseThatLookLikeDuplicates do
  let(:service) { TransactionEngine::CanonicalTransactionService::Import::EmburseThatLookLikeDuplicates.new }

  context "when there are 2 duplicate emburse_transactions" do
    before do
      duplicate_hash = "1234"
      2.times do
        create(:hashed_transaction, :emburse, primary_hash: duplicate_hash)
      end
    end

    context "when both are unprocessed" do
      it "creates a corresponding canonical_transaction for each" do
        expect do
          service.run
        end.to change(CanonicalTransaction, :count).by(2)

        CanonicalTransaction.last(2).each do |canonical_transaction|
          expect(canonical_transaction.hashed_transactions.count).to eq(1)
          expect(canonical_transaction.hashed_transactions.first.raw_emburse_transaction).to be_present
        end
      end
    end

    context "when only one is unprocessed" do
      before do
        _process_first_hashed_transaction = create(:canonical_transaction, hashed_transactions: [HashedTransaction.first])
      end

      it "creates one canonical_transaction" do
        expect do
          service.run
        end.to change(CanonicalTransaction, :count).by(1)

        canonical_transaction = CanonicalTransaction.last
        expect(canonical_transaction.hashed_transactions.count).to eq(1)
        expect(canonical_transaction.hashed_transactions.first).to eq(HashedTransaction.last)
      end
    end
  end
end
