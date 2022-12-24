# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSession, type: :model do
  it "is valid" do
    user_session = create(:user_session)
    expect(user_session).to be_valid
  end

  it "can be searched by session_token" do
    token = SecureRandom.urlsafe_base64
    user_session = create(:user_session, session_token: token)
    expect(UserSession.find_by(session_token: token)).to eq(user_session)
  end

  context "when user is locked" do
    it "can't be created" do
      user = create(:user, locked_at: Time.now)
      expect { create(:user_session, user: user) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "can be be created when impersonated" do
      user = create(:user, locked_at: Time.now)
      admin_user = create(:user, admin_at: Time.now)
      user_session = create(:user_session, user: user, impersonated_by: admin_user)
      expect(user_session).to be_valid
    end
  end
end
