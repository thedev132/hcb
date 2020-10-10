# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPlaidTransaction, type: :model do
  fixtures "raw_plaid_transactions"

  let(:raw_plaid_transaction) { raw_plaid_transactions(:raw_plaid_transaction1) }

  it "is valid" do
    expect(raw_plaid_transaction).to be_valid
  end

  describe "#amount" do
    it "uses money gem to display amount" do
      expect(raw_plaid_transaction.amount).to eql(Money.new(100))
      expect(raw_plaid_transaction.amount_cents).to eql(100)
    end
  end
end
