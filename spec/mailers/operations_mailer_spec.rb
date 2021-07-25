# frozen_string_literal: true

require "rails_helper"

RSpec.describe OperationsMailer, type: :mailer do
  fixtures  "g_suites"

  let(:g_suite) { g_suites(:g_suite1) }
  let(:g_suite_id) { g_suite.id }

  let(:mailer) { OperationsMailer.with(g_suite_id: g_suite_id).g_suite_entering_verifying_state }

  it "renders to" do
    expect(mailer.to).to eql(["bank-alert@hackclub.com"])
  end

  it "renders subject" do
    expect(mailer.subject).to eql("[OPS] [ACTION] [GSuite] Verify event1.example.com")
  end

  it "includes verification url in body" do
    expect(mailer.body).to include(g_suite.verification_url)
  end
end
