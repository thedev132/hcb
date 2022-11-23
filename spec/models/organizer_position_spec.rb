# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizerPosition, type: :model do
  let(:organizer_position) { create(:organizer_position) }

  it "is valid" do
    expect(organizer_position).to be_valid
  end

  context "missing user" do
    before do
      organizer_position.user = nil
    end

    it "is not valid" do
      expect(organizer_position).to_not be_valid
    end
  end

  context "missing event" do
    before do
      organizer_position.event = nil
    end

    it "is not valid" do
      expect(organizer_position).to_not be_valid
    end
  end
end
