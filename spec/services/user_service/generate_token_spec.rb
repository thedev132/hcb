# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::GenerateToken, type: :model do
  fixtures  "users"
  
  let(:user) { users(:user1) }

  let(:user_id) { user.id }
  
  let(:attrs) do
    {
      user_id: user_id
    }
  end

  let(:service) { UserService::GenerateToken.new(attrs) }

  it "returns the token" do
    token = service.run

    expect(token).to start_with("tok_")
  end

  it "creates a login token object" do
    expect do
      service.run
    end.to change(LoginToken, :count).by(1)
  end
end
