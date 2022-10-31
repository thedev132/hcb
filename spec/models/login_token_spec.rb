# frozen_string_literal: true

require "rails_helper"

RSpec.describe LoginToken, type: :model do
  let(:login_token) { create(:login_token) }

  it "is valid" do
    expect(login_token).to be_valid
  end

  context "when attempting to create a login token that already exists" do
    let(:attrs) do
      {
        user: login_token.user,
        token: login_token.token,
        expiration_at: Time.now
      }
    end

    it "fails" do
      expect do
        LoginToken.create!(attrs)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
