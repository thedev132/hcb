# frozen_string_literal: true

require "rails_helper"

RSpec.describe HashedTransaction, type: :model do
  fixtures "hashed_transactions"

  let(:hashed_transaction) { hashed_transactions(:hashed_transaction1) }

  it "is valid" do
    expect(hashed_transaction).to be_valid
  end
end
