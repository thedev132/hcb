# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::HashedTransactionService::RawCsvTransaction::Import do
  let!(:raw_csv_transaction) { create(:raw_csv_transaction) }

  let(:service) { TransactionEngine::HashedTransactionService::RawCsvTransaction::Import.new }

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

    context "when new raw csv transaction is added" do
      before do
        attrs = raw_csv_transaction.attributes
        attrs.delete("id")

        RawCsvTransaction.create!(attrs)
      end

      it "changes count" do
        expect do
          service.run
        end.to change(HashedTransaction, :count).by(1)
      end
    end
  end
end
