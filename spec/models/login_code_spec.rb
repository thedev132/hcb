# frozen_string_literal: true

require "rails_helper"

describe LoginCode do
  around(:example) do |example|
    Timeout.timeout(5, Timeout::Error, "Possible infinite loop", &example)
  end

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
      login_code = create(:login_code, used_at: nil)
      expect(login_code).to be_active
    end

    it "is false when used_at is present" do
      login_code = create(:login_code, used_at: DateTime.current)
      expect(login_code).to_not be_active
    end

    it "is false when expired" do
      login_code = create(:login_code)
      expect(login_code).to be_active

      travel LoginCode::EXPIRATION + 1.second

      expect(login_code).to_not be_active
    end
  end

  describe "#generate_code" do
    it "doesn't randomize when a specific code is provided" do
      login_code = create(:login_code, code: "123456")
      expect(login_code.code).to eq("123456")
    end

    it "retrys when colliding with an existing login code" do
      create(:login_code, code: "123456")

      expect(SecureRandom).to receive(:random_number).twice.with(999_999).and_return(123456, 495802)

      login_code = create(:login_code)
      expect(login_code.code).to eq("495802")
    end

    it "allows login codes to be reused after expiration" do
      create(:login_code, code: "123456")

      travel LoginCode::EXPIRATION + 1.second

      expect(create(:login_code, code: "123456")).to be_valid
      expect(LoginCode.where(code: "123456").count).to eq(2)
      expect(LoginCode.active.where(code: "123456").count).to eq(1)
    end
  end
end
