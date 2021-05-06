# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalEventMapping, type: :model do
  fixtures  "events", "canonical_transactions", "canonical_event_mappings"

  let(:canonical_event_mapping) { canonical_event_mappings(:canonical_event_mapping1) }

  it "is valid" do
    expect(canonical_event_mapping).to be_valid
  end

  context "when attempting to create a duplicate canonical event mapping" do
    it "fails" do
      expect do
        CanonicalEventMapping.create!(event: canonical_event_mapping.event, canonical_transaction: canonical_event_mapping.canonical_transaction)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
