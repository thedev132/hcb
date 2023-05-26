# frozen_string_literal: true

require "rails_helper"

describe LoginCode do
  context "when LoginCode is created" do
    it "is valid and generates a code" do
      login_code = create(:login_code)
      expect(login_code.code.length).to eq(6)
      expect(login_code).to be_valid
    end
  end

  describe "#pretty" do
    it "formats with a - in the middle" do
      login_code = create(:login_code)
      expect(login_code.pretty.length).to eq(7)
      expect(login_code.pretty[3]).to eq("-")
    end
  end

  describe "#active?" do
    it "is true when used_at is nil" do
      login_code = build(:login_code, used_at: nil)
      expect(login_code).to be_active
    end

    it "is true when used_at is present" do
      login_code = build(:login_code, used_at: DateTime.current)
      expect(login_code).to_not be_active
    end
  end
end
