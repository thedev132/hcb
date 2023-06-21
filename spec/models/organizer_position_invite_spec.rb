# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizerPositionInvite, type: :model do
  it "is valid" do
    organizer_position_invite = create(:organizer_position_invite)
    expect(organizer_position_invite).to be_valid
  end

  context "missing sender" do
    it "is not valid" do
      organizer_position_invite = create(:organizer_position_invite)
      organizer_position_invite.sender = nil

      expect(organizer_position_invite).to_not be_valid
    end
  end

  context "missing event" do
    it "is not valid" do
      organizer_position_invite = create(:organizer_position_invite)
      organizer_position_invite.event = nil

      expect(organizer_position_invite).to_not be_valid
    end
  end

  context "has user" do
    it "returns user" do
      user = create(:user)
      organizer_position_invite = create(:organizer_position_invite, user:)

      expect(organizer_position_invite.user).to eq(user)
    end
  end
end
