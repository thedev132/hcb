# frozen_string_literal: true

require "rails_helper"

RSpec.describe CanonicalTransactionService::SetEvent do
  let(:event) { create(:event) }
  let(:user) { create(:user) }

  context "when a canonical_transaction has a canonical_event_mapping" do
    let(:canonical_event_mapping) { create(:canonical_event_mapping, event:) }
    let(:canonical_transaction) { canonical_event_mapping.canonical_transaction }

    it "deletes the old mapping" do
      described_class.new(canonical_transaction_id: canonical_transaction.id,
                          event_id: event.id,
                          user:).run

      expect(CanonicalEventMapping.exists?(id: canonical_event_mapping.id)).to eq(false)
    end

    it "creates a new mapping" do
      described_class.new(canonical_transaction_id: canonical_transaction.id,
                          event_id: event.id,
                          user:).run

      canonical_transaction.reload
      expect(canonical_transaction.canonical_event_mapping.event).to eq(event)
    end
  end
end
