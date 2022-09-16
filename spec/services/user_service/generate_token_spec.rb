# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::GenerateToken, type: :model do
  let(:user) { create(:user) }
  let(:partner) { create(:partner) }

  let(:service) do
    UserService::GenerateToken.new(
      user_id: user.id,
      partner_id: partner.id
    )
  end

  it "returns the token" do
    login_token = service.run

    expect(login_token.token).to start_with("tok_")
  end

  it "creates a login token object" do
    expect do
      service.run
    end.to change(LoginToken, :count).by(1)
  end
end
