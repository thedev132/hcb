# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuite, type: :model do
  fixtures "g_suites"

  let(:g_suite) { g_suites(:g_suite1) }

  it "is valid" do
    expect(g_suite).to be_valid
  end

  context "when domain is nil" do
    it "is not valid" do
      g_suite.domain = nil

      expect(g_suite).to_not be_valid
    end
  end

  describe "#verification_url" do
    it "generates it" do
      result = g_suite.verification_url

      expect(result).to eql("https://www.google.com/webmasters/verification/verification?siteUrl=http://event1.example.com")
    end
  end
end

