# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::OrganizationContract, type: :model do
  let(:organization_identifier) { "org_1234" }

  let(:attrs) do
    {
      organizationIdentifier: organization_identifier
    }
  end

  let(:contract) { Api::V2::OrganizationContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
