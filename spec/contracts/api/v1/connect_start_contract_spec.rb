# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ConnectStartContract, type: :model do
  let(:organization_identifier) { "org_1234" }
  let(:redirect_url) { "http://example.com/redirect" }
  let(:webhook_url) { "http://example.com/webhook" }

  let(:attrs) do
    {
      organizationIdentifier: organization_identifier,
      redirectUrl: redirect_url,
      webhookUrl: webhook_url
    }
  end

  let(:contract) { Api::V1::ConnectStartContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
