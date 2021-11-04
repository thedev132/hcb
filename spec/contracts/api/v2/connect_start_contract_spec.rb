# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::PartneredSignupsNewContract, type: :model do
  let(:organization_name) { "org_1234" }
  let(:redirect_url) { "http://example.com/redirect" }

  let(:attrs) do
    {
      organization_name: organization_name,
      redirect_url: redirect_url,
    }
  end

  let(:contract) { Api::V2::PartneredSignupsNewContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
