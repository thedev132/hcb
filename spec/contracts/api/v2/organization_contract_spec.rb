# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::OrganizationContract, type: :model do
  let(:contract) { Api::V2::OrganizationContract.new.call(public_id: "org_1234") }

  it "is successful" do
    expect(contract).to be_success
  end
end
