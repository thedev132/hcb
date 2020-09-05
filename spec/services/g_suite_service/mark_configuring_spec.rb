# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::MarkConfiguring, type: :model do
  fixtures  "g_suites"
  
  let(:g_suite) { g_suites(:g_suite1) }

  let(:attrs) do
    {
      g_suite_id: g_suite.id
    }
  end

  let(:service) { GSuiteService::MarkConfiguring.new(attrs) }

  it "changes state" do
    expect(g_suite).not_to be_configuring

    service.run

    expect(g_suite.reload).to be_configuring
  end

  context "verification_key is not present" do
    before do
      g_suite.verification_key = nil
      g_suite.save!
    end

    it "raises an argument error" do
      expect do
        service.run
      end.to raise_error(ArgumentError)

      expect(g_suite.reload).to be_creating
    end
  end
end

