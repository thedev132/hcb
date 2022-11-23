# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sponsor, type: :model do
  let(:sponsor) { create(:sponsor) }

  it "is valid" do
    expect(sponsor).to be_valid
  end
end
