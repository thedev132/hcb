# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::PartneredSignupsNewContract, type: :model do
  let(:contract) {
    Api::V2::PartneredSignupsNewContract.new.call(
      organization_name: "org_1234",
      redirect_url: "http://example.com/redirect",
      owner_email: "owner@example.com",
      owner_name: "owner"
    )
  }

  it "is successful with all required fields" do
    expect(contract).to be_success
  end
end
