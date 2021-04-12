# frozen_string_literal: true

require "rails_helper"

RSpec.describe LobAddress, type: :model do
  fixtures "lob_addresses"

  let(:lob_address) { lob_addresses(:lob_address1) }

  it "is valid" do
    expect(lob_address).to be_valid
  end
end
