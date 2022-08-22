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


end
