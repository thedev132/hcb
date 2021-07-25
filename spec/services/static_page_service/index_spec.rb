# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaticPageService::Index, type: :model do
  fixtures  "users", "events",  "g_suites", "organizer_positions"

  let(:current_user) { users(:user1) }

  let(:attrs) do
    {
      current_user: current_user
    }
  end

  let(:service) { StaticPageService::Index.new(attrs) }

  describe "#events" do
    it "returns events for that user" do
      result = service.events

      expect(result.count).to eql(2)
    end
  end

  describe "#invites" do
    it "returns invites for that user" do
      result = service.invites

      expect(result.count).to eql(0)
    end

    context "when the user is part of the invites " do
      let(:current_user) { users(:user2) }

      it "returns invites" do
        result = service.invites

        expect(result.count).to eql(1)
      end
    end
  end

  describe "#redirect_to_first_event?" do
    it "returns false" do
      result = service.redirect_to_first_event?

      expect(result).to eql(false)
    end

    context "when only 1 event and zero invites and not admin" do
      before do
        allow(service).to receive(:admin?).and_return(false)
        allow(service).to receive(:events).and_return([current_user.events.first])
        allow(service).to receive(:invites).and_return([])
      end

      it "returns true" do
        result = service.redirect_to_first_event?

        expect(result).to eql(true)
      end
    end
  end

  describe "private" do
    describe "#admin?" do
      it "returns true" do
        result = service.send(:admin?)

        expect(result).to eql(true)
      end
    end
  end
end
