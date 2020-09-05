# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaidTransaction, type: :model do
  fixtures "plaid_transactions"

  let(:plaid_transaction) { plaid_transactions(:plaid_transaction1) }

  it "is valid" do
    expect(plaid_transaction).to be_valid
  end

  describe "#amount" do
    it "uses money gem to display amount" do
      expect(plaid_transaction.amount).to eql(Money.new(100))
      expect(plaid_transaction.amount_cents).to eql(100)
    end
  end
end
