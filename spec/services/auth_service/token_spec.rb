# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthService::Token, type: :model do
  let(:login_token) { create(:login_token) }

  let(:service) { AuthService::Token.new(token: login_token.token) }

  it "returns the user" do
    result = service.run

    expect(result).to eql(login_token.user)
  end

  context "when missing login token" do
    let(:service) { AuthService::Token.new(token: "doesnotexist") }

    it "raises unauthenticated error" do
      expect do
        service.run
      end.to raise_error(UnauthenticatedError)
    end
  end

  context "when token exists but is not active" do
    before do
      login_token.expiration_at = Time.now.utc - 1.minute
      login_token.save!
    end

    it "raises unauthenticated error" do
      expect do
        service.run
      end.to raise_error(UnauthenticatedError)
    end
  end
end
