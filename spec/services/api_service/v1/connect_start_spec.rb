# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::ConnectStart, type: :model do
  fixtures "partners"

  let(:organization_identifier) { "org_1234" }
  let(:redirect_url) { "http://example.com/redirect" }
  let(:webhook_url) { "http://example.com/webhook" }

  let(:attrs) do
    {
      organization_identifier: organization_identifier,
      redirect_url: redirect_url,
      webhook_url: webhook_url
    }
  end

  let(:service) { ApiService::V1::ConnectStart.new(attrs) }

  it "creates an organization" do
    expect do
      service.run
    end.to change(Event, :count).by(1)
  end

  it "creates with the redirect url" do
    event = service.run

    expect(event.redirect_url).to eql(redirect_url)
  end

  it "idempotently creates" do
    service.run

    expect do
      service.run
    end.to_not raise_error
  end
end
