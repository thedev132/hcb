# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::CanonicalTransactionService::Import::Simple do
  let(:service) { TransactionEngine::CanonicalTransactionService::Import::Simple.new }

  before do
    # This creates a HashedTransaction that has already been processed
    # (i.e. a corresponding CanonicalTransaction was linked to it via a CanonicalHashedMapping)
    # This is required for the test because the service does a NOT IN query based on a list of
    # processed HashedTransactions, so if there are no processed HashedTransactions, the query is a NOT IN ()
    # which returns nothing
    _already_processed_hashed_transaction = create(:canonical_transaction)
  end

  context "when there is an unprocessed hashed_transaction" do
    it "creates a corresponding canonical_transaction" do
      hashed_transaction = create(:hashed_transaction, :plaid)

      expect do
        service.run
      end.to change(CanonicalTransaction, :count).by(1)

      canonical_transaction = CanonicalTransaction.last
      expect(canonical_transaction.hashed_transactions.count).to eq(1)
      expect(canonical_transaction.hashed_transactions.first).to eq(hashed_transaction)
    end
  end
end
