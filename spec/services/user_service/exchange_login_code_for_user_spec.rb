# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::ExchangeLoginCodeForUser, type: :model do
  fixtures  "users"
  
  let(:user) { users(:user1) }

  let(:user_id) { 1234 }
  let(:login_code) { "555-555" }

  let(:auth_token) { "abcd" }
  
  let(:attrs) do
    {
      user_id: user_id,
      login_code: login_code
    }
  end

  let(:service) { UserService::ExchangeLoginCodeForUser.new(attrs) }

  let(:exchange_login_code_resp) do
    {
      auth_token: auth_token
    }
  end

  let(:exchange_login_code_error_resp) do
    {
      errors: [ "error" ]
    }
  end

  let(:get_user_resp) do
    {
      email: user.email,
      admin_at: user.admin_at
    }
  end


  before do
    allow(service).to receive(:exchange_login_code_resp).and_return(exchange_login_code_resp)
    allow(service).to receive(:get_user_resp).and_return(get_user_resp)
  end

  it "returns the user" do
    user = service.run

    expect(user.id).to eql(user.id)
  end

  context "when login code response has errors" do
    before do
      allow(service).to receive(:exchange_login_code_resp).and_return(exchange_login_code_error_resp)
    end

    it "raises error" do
      expect do
        service.run
      end.to raise_error(::Errors::InvalidLoginCode)
    end
  end
end
