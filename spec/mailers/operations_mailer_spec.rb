# frozen_string_literal: true

require "rails_helper"

RSpec.describe OperationsMailer, type: :mailer do
  let(:g_suite) { create(:g_suite) }

  let(:mailer) { OperationsMailer.with(g_suite_id: g_suite.id).g_suite_entering_verifying_state }

  it "renders to" do
    expect(mailer.to).to eql(["hcb@hackclub.com"])
  end

  it "renders subject" do
    expect(mailer.subject).to eql("[OPS] [ACTION] [Google Workspace] Verify #{g_suite.domain}")
  end

  it "includes verification url in body" do
    expect(mailer.body).to include(google_workspace_process_admin_url(g_suite))
  end
end
