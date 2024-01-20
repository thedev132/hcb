# frozen_string_literal: true

require "rails_helper"

describe HcbCodeService::FindOrCreate do

  context "when hcb_code doesn't exist" do
    let(:hcb_code) { "HCB-401-1" }

    it "creates a new one and returns it" do
      hcb_code_record = described_class.new(hcb_code:).run

      expect(hcb_code_record).to be_a(HcbCode)
      expect(hcb_code_record.persisted?).to eq(true)
      expect(hcb_code_record.hcb_code).to eq(hcb_code)
    end
  end
end
