# frozen_string_literal: true

require "rails_helper"

describe HcbCodeService::CanDispute do

  context "when it's an invalid transaction" do
    let(:hcb_code) { build_stubbed(:hcb_code) }

    it "returns false" do
      result, error_reason = described_class.new(hcb_code:).run

      expect(result).to eq(false)
      expect(error_reason).to eq("This is not a valid transaction")
    end
  end

  context "when it's valid transaction but not a stripe transaction" do
    let(:hcb_code) { build_stubbed(:hcb_code) }

    it "returns false" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)

      result, error_reason = described_class.new(hcb_code:).run

      expect(result).to eq(false)
      expect(error_reason).to eq("Can not dispute this type of transaction")
    end
  end


  context "when stripe transaction is older than 90 days" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns false" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(true)
      allow(hcb_code).to receive(:date).and_return(Date.today - 91.days)

      result, error_reason = described_class.new(hcb_code:).run

      expect(result).to eq(false)
      expect(error_reason).to eq("Card transactions older than 90 days can not be disputed.")
    end
  end

  context "when it's a bank transaction older than 90 days" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns false" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(false)
      allow(hcb_code).to receive(:unknown?).and_return(true)
      allow(hcb_code).to receive(:date).and_return(Date.today - 91.days)
      allow(hcb_code).to receive(:amount_cents).and_return(-1)

      result, error_reason = described_class.new(hcb_code:).run

      expect(result).to eq(false)
      expect(error_reason).to eq("Bank account transactions older than 90 days can not be disputed.")
    end
  end

  context "when stripe transaction is newer than 90 days" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns true" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(true)
      allow(hcb_code).to receive(:date).and_return(Date.today - 90.days)

      result, = described_class.new(hcb_code:).run

      expect(result).to eq(true)
    end
  end

  context "when transaction is a donation" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns true" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(false)
      allow(hcb_code).to receive(:donation?).and_return(true)

      result, = described_class.new(hcb_code:).run

      expect(result).to eq(true)
    end
  end

  context "when transaction is a partner donation" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns true" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(false)
      allow(hcb_code).to receive(:donation?).and_return(true)

      result, = described_class.new(hcb_code:).run

      expect(result).to eq(true)
    end
  end


  context "when transaction is a bank transaction newer than 90 days" do
    let(:hcb_code) { build_stubbed(:hcb_code) }
    it "returns true" do
      allow(hcb_code).to receive(:no_transactions?).and_return(false)
      allow(hcb_code).to receive(:stripe_card?).and_return(false)
      allow(hcb_code).to receive(:unknown?).and_return(true)
      allow(hcb_code).to receive(:date).and_return(Date.today - 90.days)

      result, = described_class.new(hcb_code:).run

      expect(result).to eq(true)
    end
  end
end
