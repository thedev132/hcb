# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ConnectStartContract, type: :model do
  let(:organization_name) { "org_1234" }
  let(:redirect_url) { "http://example.com/redirect" }

  let(:attrs) do
    {
      organization_name: organization_name,
      redirect_url: redirect_url,
    }
  end

  let(:contract) { Api::V1::ConnectStartContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
