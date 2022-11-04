# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::LoginContract, type: :model do
  context "when login_token is present" do
    let(:contract) { Api::V2::LoginContract.new.call(login_token: "tok_1234") }

    it "is successful" do
      expect(contract).to be_success
    end
  end

  context "when login_token is missing" do
    let(:contract) { Api::V2::LoginContract.new.call(login_token: "") }

    it "is unsuccessful" do
      expect(contract).to_not be_success
    end
  end
end
