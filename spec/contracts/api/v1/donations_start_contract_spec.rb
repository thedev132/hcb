# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::DonationsStartContract, type: :model do
  let(:organization_identifier) { "org_1234" }

  let(:attrs) do
    {
      organizationIdentifier: organization_identifier
    }
  end

  let(:contract) { Api::V1::DonationsStartContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end

  context "missing organizationIdentifier" do
    let(:organization_identifier) { "" }

    it "fails" do
      expect(contract).to_not be_success
    end
  end
end
