# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventMappingEngine::GuessEventId::FeeReimbursement do
  fixtures :canonical_transactions, :hashed_transactions, :raw_plaid_transactions, :canonical_hashed_mappings, :transactions, :fee_reimbursements, :events, :donations

  let(:canonical_transaction) { canonical_transactions(:canonical_transaction3) }
  let(:event) { events(:event1) }

  let(:attrs) do
    {
      canonical_transaction: canonical_transaction
    }
  end

  let(:service) { EventMappingEngine::GuessEventId::FeeReimbursement.new(attrs) }

  it "returns event id" do
    result = service.run

    expect(result).to eql(event.id)
  end
end
