# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::Update, type: :model do
  fixtures   "users", "g_suites"

  let(:user) { users(:user1) }
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

  context "when verification key is changed" do
    it "puts it into configuring state" do
      original_aasm_state = g_suite.aasm_state

      g_suite_result = service.run

      expect(g_suite_result.aasm_state).to_not eql(original_aasm_state)
      expect(g_suite_result.aasm_state).to eql("configuring")
    end

    it "updates g suite" do
      original_verification_key = g_suite.verification_key

      g_suite_result = service.run

      expect(g_suite_result.verification_key).not_to eql(original_verification_key)
    end

    it "does not send a mailer" do
      expect do
        service.run
      end.to_not change(ActionMailer::Base.deliveries, :count)
    end

    context "when g_suite has created_by" do
      before do
        g_suite.created_by = user
        g_suite.save!
      end

      it "does send 1 mailer" do
        expect do
          service.run
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        mail = ActionMailer::Base.deliveries.last

        expect(mail.to).to eql([user.email])
        expect(mail.subject).to include(domain)
      end
    end
  end

  context "when domain is changed" do
    let(:domain) { "newdomain.com" }

    before do
      g_suite.mark_configuring!
    end

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

    it "changes status back to creating and sets verification key to nil (even though it was attempted to be set)" do
      original_aasm_state = g_suite.aasm_state
      original_verification_key = g_suite.verification_key

      g_suite_result = service.run

      expect(g_suite_result.aasm_state).not_to eql(original_aasm_state)
      expect(g_suite_result.aasm_state).to eql("creating")
      expect(g_suite_result.verification_key).not_to eql(original_verification_key)
      expect(g_suite_result.verification_key).to eql(nil)
    end
  end

  it "sends 0 mailers" do
    service.run

    count = ActionMailer::Base.deliveries.count

    expect(count).to eql(0)
  end
end
