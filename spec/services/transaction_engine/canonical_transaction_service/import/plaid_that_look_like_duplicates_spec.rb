# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::CanonicalTransactionService::Import::PlaidThatLookLikeDuplicates do
  let(:service) { TransactionEngine::CanonicalTransactionService::Import::PlaidThatLookLikeDuplicates.new }

  context "when there are 2 actually duplicate plaid_transactions" do
    before do
      duplicate_hash = "1234"
      2.times do
        # transactions are duplicate if they have same hash but different raw_plaid_transactions
        create(:hashed_transaction, primary_hash: duplicate_hash, raw_plaid_transaction: create(:raw_plaid_transaction))
      end
    end

    context "when both are unprocessed" do
      it "creates only one CanonicalTransaction (i.e. skips one duplicate)" do
        expect do
          service.run
        end.to change(CanonicalTransaction, :count).by(1)

        number_of_processed_hashed_transactions = HashedTransaction.count { |ht| ht.canonical_transaction.present? }
        expect(number_of_processed_hashed_transactions).to eq(1)
        number_of_unprocessed_hashed_transactions = HashedTransaction.count { |ht| ht.canonical_transaction.nil? }
        expect(number_of_unprocessed_hashed_transactions).to eq(1)
      end
    end

    context "when only one is unprocessed" do
      before do
        _process_first_hashed_transaction = create(:canonical_transaction, hashed_transactions: [HashedTransaction.first])
      end

      it "does not create any CanonicalTransactions, since the duplicate has already been processed" do
        expect do
          service.run
        end.to change(CanonicalTransaction, :count).by(0)
      end
    end
  end

  context "when there are 2 not actually duplicate plaid_transactions" do
    before do
      # same hash and same raw_plaid_transaction are not considered duplicates
      raw_plaid_transaction = create(:raw_plaid_transaction)
      duplicate_hash = "1234"
      2.times do
        create(:hashed_transaction, primary_hash: duplicate_hash, raw_plaid_transaction: raw_plaid_transaction)
      end
    end

    context "when both are unprocessed" do
      it "creates a corresponding canonical_transaction for each" do
        expect do
          service.run
        end.to change(CanonicalTransaction, :count).by(2)

        CanonicalTransaction.last(2).each do |canonical_transaction|
          expect(canonical_transaction.hashed_transactions.count).to eq(1)
          expect(canonical_transaction.hashed_transactions.first.raw_plaid_transaction).to be_present
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
