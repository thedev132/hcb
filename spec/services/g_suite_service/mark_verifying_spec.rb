# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::MarkVerifying, type: :model do
  fixtures  "g_suites"
  
  let(:g_suite) { g_suites(:g_suite1) }

  let(:attrs) do
    {
      g_suite_id: g_suite.id
    }
  end

  let(:service) { GSuiteService::MarkVerifying.new(attrs) }

  it "changes state" do
    expect(g_suite).not_to be_verifying

    service.run

    expect(g_suite.reload).to be_verifying
  end

  it "sends a mailer" do # TODO
    service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to eql(["bank-alerts@hackclub.com"])
    expect(mail.subject).to include("[OPS] [ACTION] [GSuite]")
  end
end

