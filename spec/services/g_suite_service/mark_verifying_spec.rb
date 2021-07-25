# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::MarkVerifying, type: :model do
  fixtures  "g_suites"

  let(:g_suite) { g_suites(:g_suite3) }

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

  it "sends a mailer" do
    service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to eql(["bank-alert@hackclub.com"])
    expect(mail.subject).to include("[OPS] [ACTION] [GSuite]")
  end

  context "mailer 3rd party fails" do
    before do
      allow_any_instance_of(OperationsMailer).to receive(:g_suite_entering_verifying_state).and_raise(ArgumentError)
    end

    it "rolls back state" do
      expect do
        service.run
      end.to raise_error(ArgumentError)

      expect(g_suite.reload).to be_configuring
    end
  end
end
