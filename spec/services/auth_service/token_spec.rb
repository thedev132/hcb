# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthService::Token, type: :model do
  fixtures "users", "login_tokens"

  let(:login_token) { login_tokens(:login_token1) }
  let(:token) { login_token.token }

  let(:attrs) do
    {
      token: token,
    }
  end

  let(:service) { AuthService::Token.new(attrs) }

  it "returns the user" do
    result = service.run

    expect(result).to eql(login_token.user)
  end

  context "when missing login token" do
    let(:token) { "doesnotexist" }

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
