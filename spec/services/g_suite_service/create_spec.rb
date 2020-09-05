# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::Create, type: :model do
  fixtures  "users", "events",  "g_suites"
  
  let(:event) { events(:event1) }
  let(:current_user) { users(:user1) }
  let(:event_id) { event.id }
  let(:domain) { "event99.example.com" }

  let(:attrs) do
    {
      current_user: current_user,
      event_id: event_id,
      domain: domain
    }
  end

  let(:service) { GSuiteService::Create.new(attrs) }

  before do
    allow_any_instance_of(::Partners::Google::GSuite::CreateDomain).to receive(:run).and_return(true)
    allow_any_instance_of(::Partners::Google::GSuite::DeleteDomain).to receive(:run).and_return(true)
  end

  it "does not create a gsuite if already created" do
    expect do
      service.run
    end.to raise_error(ArgumentError, "You already have a GSuite account for this event")
  end

  context "when g suite does not exist" do
    before do
      event.g_suite.application.destroy!
      event.g_suite.destroy!
    end

    it "creates a g suite" do
      expect do
        service.run
      end.to change(GSuite, :count).by(1)
    end

    it "sends 2 mailers" do
      service.run

      mails = ActionMailer::Base.deliveries.last(2)

      expect(mails[0].to).to eql([current_user.email])
      expect(mails[0].subject).to include(domain)

      expect(mails[1].to).to eql(["bank-alert@hackclub.com"])
      expect(mails[1].subject).to include(domain)
    end
  end
end
