# frozen_string_literal: true

require "rails_helper"

RSpec.describe Check, type: :model do
  it "is valid" do
    check = create(:check)
    expect(check).to be_valid
  end

  describe "#send_date" do
    it "must be at least 12 hours in the future" do
      check = build(:check, send_date: Time.now.utc + 1.hour)
      expect(check).to_not be_valid
    end
  end
end
