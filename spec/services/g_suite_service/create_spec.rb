# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteService::Create, type: :model do
  let(:event) { create(:event) }
  let(:current_user) { create(:user) }

  before do
    allow_any_instance_of(::Partners::Google::GSuite::CreateDomain).to receive(:run).and_return(true)
    allow_any_instance_of(::Partners::Google::GSuite::DeleteDomain).to receive(:run).and_return(true)
  end

  context "when g suite does not exist" do
    let(:domain) { "event99.example.com" }
    let(:service) do
      GSuiteService::Create.new(
        current_user: current_user,
        event_id: event.id,
        domain: domain
      )
    end

    it "creates a g suite" do
      expect do
        service.run
      end.to change(GSuite, :count).by(1)
    end

    it "sets the created_by user" do
      g_suite = service.run

      expect(g_suite.created_by).to eql(current_user)
    end

    it "sends 1 mailer" do
      service.run

      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to eql(["bank@hackclub.com"])
      expect(mail.subject).to include(domain)
    end
  end

  context "when gsuite already exists" do
    let(:service) do
      GSuiteService::Create.new(
        current_user: current_user,
        event_id: event.id,
        domain: "newdomain.example.com"
      )
    end

    before do
      create(:g_suite, event: event)
    end

    it "does not create a new gsuite" do
      expect do
        service.run
      end.to raise_error(ArgumentError, "You already have a GSuite account for this event")
    end
  end

end
