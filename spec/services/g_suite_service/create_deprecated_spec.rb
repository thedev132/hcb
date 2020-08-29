# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::CreateDeprecated, type: :model do
  fixtures  "users", "events",  "g_suites", "g_suite_applications"
  
  let(:event1) { events(:event1) }
  let(:g_suite_application) { g_suite_applications(:g_suite_application3) }
  let(:current_user) { users(:user1) }
  let(:event_id) { event1.id }
  let(:domain) { g_suite_application.domain } # MATCH REQUIRED. TODO: unravel domain as the linkage mechanism.
  let(:verification_key) { "abcd" }
  let(:dkim_key) { "efgh" }
  
  let(:attrs) do
    {
      current_user: current_user,
      event_id: event_id,
      g_suite_application: g_suite_application,
      domain: domain,
      verification_key: verification_key,
      dkim_key: dkim_key
    }
  end

  let(:service) { GSuiteService::CreateDeprecated.new(attrs) }

  it "creates a gsuite" do
    expect do
      service.run
    end.to change(GSuite, :count).by(1)
  end

  it "sends a mailer" do
    service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to eql([current_user.email])
    expect(mail.subject).to include(domain)
  end

  it "changes the application values" do
    expect do
      service.run
    end.to change(g_suite_application, :accepted_at).and change(g_suite_application, :fulfilled_by)
  end

  context "when domain from g suite application does not match proposed domain for g suite" do
    let(:domain) { "different.com" }

    it "still permits creation as long as it does not exist" do
      expect do
        service.run
      end.to change(GSuite, :count)
    end
  end
end

