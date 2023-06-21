# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::Create, type: :model do
  let(:event) { create(:event) }

  context "when the user doesn't exist" do
    let!(:service) do
      UserService::Create.new(
        event_id: event.id,
        email: "newuser@example.com",
        full_name: "New User",
        phone_number: "+13105551234"
      )
    end

    it "creates a user" do
      expect do
        service.run
      end.to change(User, :count).by(1)
    end

    it "creates the organizer position" do
      expect do
        service.run
      end.to change(OrganizerPosition, :count).by(1)
    end
  end

  context "when user already exists" do
    let(:user) { create(:user) }

    let!(:service) do
      UserService::Create.new(
        event_id: event.id,
        email: user.email,
        full_name: "Existing User",
        phone_number: "+13105551234"
      )
    end

    context "but is not an organizer of the event" do
      it "does not create the user" do
        expect do
          service.run
        end.not_to change(User, :count)
      end

      it "does create the organizer position" do
        expect do
          service.run
        end.to change(OrganizerPosition, :count).by(1)
      end

    end

    context "and is already an organizer of the event" do
      before do
        # user is already organizer of event
        create(:organizer_position, event: event, user: user)
      end

      it "does not create the user" do
        expect do
          service.run
        end.not_to change(User, :count)
      end

      it "does not create the organizer position" do
        expect do
          service.run
        end.not_to change(OrganizerPosition, :count)
      end
    end
  end
end
