# frozen_string_literal: true

require "rails_helper"

RSpec.describe HashedTransaction, type: :model do
  it "is valid with trait plaid" do
    hashed_transaction = create(:hashed_transaction, :plaid)
    expect(hashed_transaction).to be_valid
  end

  it "is valid with trait emburse" do
    hashed_transaction = create(:hashed_transaction, :emburse)
    expect(hashed_transaction).to be_valid
  end

  describe "#memo" do
    context "source is emburse without memo details and a negative amount_cents" do
      let(:hashed_transaction) { create(:hashed_transaction, :emburse) }

      before do
        hashed_transaction.raw_emburse_transaction.update_column(:amount_cents, -300)
      end

      it "generates blank memo" do
        expect(hashed_transaction.memo).to eql("")
      end
    end
  end
end
