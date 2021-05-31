# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partner, type: :model do
  fixtures "partners"

  let(:partner) { partners(:partner1) }

  it "is valid" do
    expect(partner).to be_valid
  end
end
