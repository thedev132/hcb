# frozen_string_literal: true

require "rails_helper"

RSpec.describe Disbursement, type: :model do
  fixtures "disbursements", "events"
  let(:disbursement) { disbursements(:user_created) }

  it "is valid" do
    expect(disbursement).to be_valid
  end
end
