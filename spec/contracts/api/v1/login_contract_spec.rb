# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LoginContract, type: :model do
  let(:login_token) { "tok_1234" }

  let(:attrs) do
    {
      loginToken: login_token
    }
  end

  let(:contract) { Api::V1::LoginContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end

  context "when missing loginToken" do
    let(:login_token) { "" }

    it "is unsuccessful" do
      expect(contract).to_not be_success
    end
  end
end
