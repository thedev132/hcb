# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::MarkVerified, type: :model do
  fixtures  "g_suites"
  
  let(:g_suite) { g_suites(:g_suite2) }

  let(:attrs) do
    {
      g_suite_id: g_suite.id
    }
  end

  let(:service) { GSuiteService::MarkVerified.new(attrs) }

  before do
    allow(service).to receive(:verified_on_google?).and_return(true)
  end

  it "changes state" do
    expect(g_suite).not_to be_verified

    service.run

    expect(g_suite.reload).to be_verified
  end

  context "when verified is false" do
    before do
      allow(service).to receive(:verified_on_google?).and_return(false)
    end

    it "does not change state" do
      service.run

      expect(g_suite.reload).to_not be_verified
    end
  end

  context "when network or other error occurs" do
    before do
      allow(service).to receive(:verified_on_google?).and_raise(ArgumentError)
    end

    it "does not change state" do
      expect do
        service.run
      end.to raise_error(ArgumentError)

      expect(g_suite.reload).to_not be_verified
    end
  end
end
