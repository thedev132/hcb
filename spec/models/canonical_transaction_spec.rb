# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalTransaction, type: :model do
  fixtures "canonical_transactions"

  let(:canonical_transaction) { canonical_transactions(:canonical_transaction1) }

  it "is valid" do
    expect(canonical_transaction).to be_valid
  end

  describe "friendly_memo" do
    it "does not permit empty string" do
      canonical_transaction.friendly_memo = ""
      expect(canonical_transaction).to_not be_valid

      canonical_transaction.friendly_memo = " "
      expect(canonical_transaction).to_not be_valid

      canonical_transaction.friendly_memo = "Friendly Memo"
      expect(canonical_transaction).to be_valid
    end

    it "does permit nil" do
      canonical_transaction.friendly_memo = nil
      expect(canonical_transaction).to be_valid
    end
  end

  describe "custom_memo" do
    it "does not permit empty string" do
      canonical_transaction.custom_memo = ""
      expect(canonical_transaction).to_not be_valid

      canonical_transaction.custom_memo = " "
      expect(canonical_transaction).to_not be_valid

      canonical_transaction.custom_memo = "Custom Memo"
      expect(canonical_transaction).to be_valid
    end

    it "does permit nil" do
      canonical_transaction.custom_memo = nil
      expect(canonical_transaction).to be_valid
    end
  end
end
