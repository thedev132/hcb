# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  fixtures "events"

  let(:event) { events(:event1) }

  it "is valid" do
    expect(event).to be_valid
  end
end

