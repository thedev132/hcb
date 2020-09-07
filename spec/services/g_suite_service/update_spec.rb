# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::Update, type: :model do
  fixtures  "g_suites"
  
  let(:g_suite) { g_suites(:g_suite1) }
  let(:g_suite_id) { g_suite.id }
  let(:domain) { g_suite.domain }
  let(:verification_key) { "verification_keyA" }

  let(:attrs) do
    {
      g_suite_id: g_suite_id,

      domain: domain,
      verification_key: verification_key
    }
  end

  let(:service) { GSuiteService::Update.new(attrs) }

  before do
    allow_any_instance_of(::Partners::Google::GSuite::DeleteDomain).to receive(:run).and_return(true)
    allow_any_instance_of(::Partners::Google::GSuite::CreateDomain).to receive(:run).and_return(true)
  end

  it "updates g suite" do
    original_verification_key = g_suite.verification_key

    g_suite_result = service.run

    expect(g_suite_result.verification_key).not_to eql(original_verification_key)
  end

  context "when domain is changed" do
    let(:domain) { "newdomain.com" }

    it "changes domain and makes call to delete domain and create domain" do
      original_domain = g_suite.domain

      expect_any_instance_of(::Partners::Google::GSuite::DeleteDomain).to receive(:run).and_return(true)
      expect_any_instance_of(::Partners::Google::GSuite::CreateDomain).to receive(:run).and_return(true)

      g_suite_result = service.run

      expect(g_suite_result.domain).not_to eql(original_domain)
    end

    it "sends 1 mailer" do
      service.run

      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to eql(["bank-alert@hackclub.com"])
      expect(mail.subject).to include(domain)
    end
  end

  it "sends 0 mailers" do
    service.run

    count = ActionMailer::Base.deliveries.count

    expect(count).to eql(0)
  end
end
