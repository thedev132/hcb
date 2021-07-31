# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partner, type: :model do
  fixtures "partners"

  let(:partner) { partners(:partner1) }

  it "is valid" do
    expect(partner).to be_valid
  end

  it "defaults to external" do
    expect(partner).to be_external
  end

  context "when slug is reserved" do
    it "fails" do
      partner.slug = "connect"

      expect(partner).to_not be_valid
    end
  end
end
