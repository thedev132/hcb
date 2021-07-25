# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::HashedTransactionService::RawPlaidTransaction::Import do
  fixtures :raw_plaid_transactions

  let(:raw_plaid_transaction) { raw_plaid_transactions(:raw_plaid_transaction1) }

  let(:service) { TransactionEngine::HashedTransactionService::RawPlaidTransaction::Import.new }

  before do
    travel_to Time.local(2020, 9, 1)
  end

  after do
    travel_back
  end

  it "creates hashed transactions" do
    expect do
      service.run
    end.to change(HashedTransaction, :count).by(1)
  end

  context "when run twice" do
    before do
      service.run
    end

    it "is idempotent and does not change the count" do
      expect do
        service.run
      end.to_not change(HashedTransaction, :count)
    end

    context "when new raw plaid transaction is added" do
      before do
        attrs = raw_plaid_transaction.attributes
        attrs.delete("id")
        attrs["plaid_transaction_id"] = "plaid_transaction_id99"

        RawPlaidTransaction.create!(attrs)
      end

      it "changes count" do
        expect do
          service.run
        end.to change(HashedTransaction, :count).by(1)
      end
    end
  end
end
