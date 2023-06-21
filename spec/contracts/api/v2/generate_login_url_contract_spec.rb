# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::GenerateLoginUrlContract, type: :model do

  context "required fields" do
    let(:public_id) { "org_1234" }
    let(:email) { "example@example.com" }

    let(:contract) {
      Api::V2::GenerateLoginUrlContract.new.call(
        public_id:,
        email:
      )
    }

    it "is successful when all required fields are present" do
      expect(contract).to be_success
    end

    context "when missing public_id" do
      let(:public_id) { "" }

      it "is unsuccessful" do
        expect(contract).to_not be_success
      end
    end

    context "when missing email" do
      let(:email) { "" }

      it "is unsuccessful" do
        expect(contract).to_not be_success
      end
    end
  end
end
