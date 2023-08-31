# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::MarkVerifying, type: :model do
  let(:g_suite) { create(:g_suite, aasm_state: :configuring) }

  let(:service) { GSuiteService::MarkVerifying.new(g_suite_id: g_suite.id) }

  it "changes state" do
    expect(g_suite).not_to be_verifying

    service.run

    expect(g_suite.reload).to be_verifying
  end

  it "sends a mailer" do
    service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to eql(["hcb@hackclub.com"])
    expect(mail.subject).to include("[OPS] [ACTION] [Google Workspace]")
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
