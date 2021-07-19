# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::ConnectFinish, type: :model do
  fixtures "events", "users", "organizer_positions"

  let(:event) { events(:event1) }
  let(:user) { users(:user1) }

  let(:event_id) { event.id }
  let(:organization_name) { event.name }
  let(:organization_url) { "http://example.com" }
  let(:name) { user.full_name }
  let(:email) { user.email }
  let(:phone) { user.phone_number }
  let(:address) { "123 Main St" }
  let(:birthdate) { Date.new(2000, 1, 1) }

  let(:attrs) do
    {
      event_id: event_id,
      organization_name: organization_name,
      organization_url: organization_url,
      name: name,
      email: email,
      phone: phone,
      address: address,
      birthdate: birthdate
    }
  end

  let(:service) { ApiService::V1::ConnectFinish.new(attrs) }

  it "does not create event" do
    expect do
      service.run
    end.to_not change(Event, :count)
  end

  it "does not create user" do
    expect do
      service.run
    end.to_not change(User, :count)
  end

  context "when new user" do
    let(:email) { "someotheruser@example.com" }

    it "does create user" do
      expect do
        service.run
      end.to change(User, :count).by(1)
    end

    it "does create an organizer position" do
      expect do
        service.run
      end.to change(OrganizerPosition, :count).by(1)
    end
  end
end
