# frozen_string_literal: true

require "rails_helper"

RSpec.describe LobAddress, type: :model do
  it "is valid" do
    lob_address = create(:lob_address)
    expect(lob_address).to be_valid
  end
end
