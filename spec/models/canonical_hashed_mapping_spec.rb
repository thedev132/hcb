# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalHashedMapping, type: :model do
  let(:canonical_hashed_mapping) { create(:canonical_transaction).canonical_hashed_mappings.first }

  it "is valid" do
    expect(canonical_hashed_mapping).to be_valid
  end
end
