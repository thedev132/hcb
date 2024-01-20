# frozen_string_literal: true

require "rails_helper"

describe HcbCodeService::AiGenerateMemo do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }

  after do
    Faraday.default_connection = nil
  end

  let(:hcb_code) { create(:hcb_code) }
  let(:canonical_transaction) { create(:canonical_transaction, hcb_code: hcb_code.hcb_code) }

  context "when the API call succeeds" do
    it "generates a memo for the transaction" do
      generated = "DONATION FROM X"
      stubs.post("https://api.openai.com/v1/completions") do
        [
          200,
          { 'Content-Type': "application/json" },
          { "choices"=> [{ "text"=> generated }] }
        ]
      end

      result = described_class.new(hcb_code:, conn:).run
      expect(result).to eq(generated)
    end
  end

  context "when the API call fails" do
    it "returns nil" do
      stubs.post("https://api.openai.com/v1/completions") do
        [
          400,
          { 'Content-Type': "application/json" },
          { "error"=> { "message" => "Bad request" } }
        ]
      end
      result = described_class.new(hcb_code:, conn:).run

      expect(result).to eq(nil)
    end
  end
end
