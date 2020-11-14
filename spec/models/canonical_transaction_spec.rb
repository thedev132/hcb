# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalTransaction, type: :model do
  fixtures "canonical_transactions"

  let(:canonical_transaction) { canonical_transactions(:canonical_transaction1) }

  it "is valid" do
    expect(canonical_transaction).to be_valid
  end
end
