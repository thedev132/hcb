# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::Create, type: :model do
  fixtures  "users", "events", "organizer_positions"

  let(:event) { events(:event1) }

  let(:event_id) { event.id }
  let(:email) { "newuser@example.com" }
  let(:full_name) { "New User" }
  let(:phone_number) { "+13105551234" }

  let(:attrs) do
    {
      event_id: event_id,
      email: email,
      full_name: full_name,
      phone_number: phone_number
    }
  end

  let(:service) { UserService::Create.new(attrs) }

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

  context "when users already exists" do
    let(:user) { users(:user1) }
    let(:email) { user.email }

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
