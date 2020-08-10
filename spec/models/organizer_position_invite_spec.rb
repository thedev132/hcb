# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizerPositionInvite, type: :model do
  fixtures  "users", "events", "organizer_position_invites"

  let(:organizer_position_invite) { organizer_position_invites(:organizer_position_invite1) }

  it "is valid" do
    expect(organizer_position_invite).to be_valid
  end

  context "missing sender" do
    before do
      organizer_position_invite.sender = nil
    end

    it "is not valid" do
      expect(organizer_position_invite).to_not be_valid
    end
  end

  context "missing event" do
    before do
      organizer_position_invite.event = nil
    end

    it "is not valid" do
      expect(organizer_position_invite).to_not be_valid
    end
  end

  context "has user" do
    let(:organizer_position_invite) { organizer_position_invites(:organizer_position_invite2) }
    let(:user2) { users(:user2) }

    it "returns user" do
      expect(organizer_position_invite.user).to eql(user2)
    end
  end
end
