# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::DonationsNewContract, type: :model do
  context "when organization_id is present" do
    let(:contract) {
      Api::V2::DonationsNewContract.new.call(
        organization_id: "org_1234"
      )
    }

    it "is successful" do
      expect(contract).to be_success
    end
  end

  context "when organization_id is missing" do
    let(:contract) {
      Api::V2::DonationsNewContract.new.call(
        organization_id: ""
      )
    }

    it "fails" do
      expect(contract).to_not be_success
    end
  end
end
