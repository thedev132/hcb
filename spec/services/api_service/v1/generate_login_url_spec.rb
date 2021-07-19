# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::GenerateLoginUrl, type: :model do
  fixtures "partners", "events", "users", "organizer_positions"

  let(:partner) { partners(:partner1) }
  let(:event) { events(:event1) }

  let(:partner_id) { partner.id }
  let(:organization_identifier) { event.organization_identifier }

  let(:attrs) do
    {
      partner_id: partner_id,
      organization_identifier: organization_identifier
    }
  end

  let(:service) { ApiService::V1::GenerateLoginUrl.new(attrs) }

  it "creates a login token" do
    expect do
      service.run
    end.to change(LoginToken, :count).by(1)
  end

  it "creates with the login url" do
    url = service.run

    expect(url).to eql("http://example.com/api/v1/login?loginToken=#{LoginToken.last.token}")
  end

  it "idempotently creates" do
    service.run

    expect do
      service.run
    end.to_not raise_error
  end

  context "when partner does not exist" do
    let(:partner_id) { "999999" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when organization identifier does not exist" do
    let(:organization_identifier) { "event8787878" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
