# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  fixtures "events", "transactions", "fee_relationships", "canonical_event_mappings", "canonical_transactions", "partners"

  let(:event) { events(:event1) }

  it "is valid" do
    expect(event).to be_valid
  end

  it "defaults to pending" do
    expect(event).to be_pending
  end

  describe "#transaction_engine_v2_at" do
    it "has a value" do
      event.save!

      result = event.transaction_engine_v2_at

      expect(result).to_not eql(nil)
    end
  end

  describe "#balance_v2_cents" do
    it "calculates a value from canonical transactions" do
      result = event.balance_v2_cents

      expect(result).to eql(100)
    end
  end

  describe "private" do
    describe "#total_fees" do
      it "calculates" do
        result = event.send(:total_fees)

        expect(result).to eql(10010.0)
      end
    end

    describe "#total_fee_payments" do
      it "calculates" do
        result = event.send(:total_fee_payments)

        expect(result).to eql(10.0)
      end
    end
  end
end
