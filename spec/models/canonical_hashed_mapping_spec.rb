# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalHashedMapping, type: :model do
  fixtures "canonical_hashed_mappings", "canonical_transactions", "hashed_transactions"

  let(:canonical_hashed_mapping) { canonical_hashed_mappings(:canonical_hashed_mapping1) }

  it "is valid" do
    expect(canonical_hashed_mapping).to be_valid
  end
end
