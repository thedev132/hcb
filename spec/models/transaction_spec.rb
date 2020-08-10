# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transaction, type: :model do
  fixtures "transactions"

  let(:transaction) { transactions(:transaction1) }

  it "is valid" do
    expect(transaction).to be_valid
  end
end
