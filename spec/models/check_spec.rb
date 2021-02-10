# frozen_string_literal: true

require "rails_helper"

RSpec.describe Check, type: :model do
  fixtures "checks"

  let(:check) { checks(:check1) }

  it "is valid" do
    expect(check).to be_valid
  end

  describe "#send_date" do
    it "must be at least 12 hours in the future" do
      check.send_date = Time.now + 1.hour

      expect(check).to_not be_valid
    end
  end
end
