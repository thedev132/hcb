# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fee, type: :model do
  fixtures "canonical_event_mappings", "fees"

  let(:fee) { fees(:fee1) }

  it "is valid" do
    expect(fee).to be_valid
  end

  describe "#reason" do
    it "is required" do
      fee.reason = nil

      expect(fee).to_not be_valid
    end
  end

  describe "#amount_cents_as_decimal" do
    it "must be positive integer" do
      fee.amount_cents_as_decimal = 0.0
      expect(fee).to be_valid

      fee.amount_cents_as_decimal = -2.2
      expect(fee).not_to be_valid
    end
  end

  describe "#event_sponsorship_fee" do
    it "must be positive integer" do
      fee.event_sponsorship_fee = 0.0
      expect(fee).to be_valid

      fee.event_sponsorship_fee = -2.2
      expect(fee).not_to be_valid
    end
  end

end
