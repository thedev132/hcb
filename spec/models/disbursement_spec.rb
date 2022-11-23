# frozen_string_literal: true

require "rails_helper"

RSpec.describe Disbursement, type: :model do
  let(:disbursement) { create(:disbursement) }

  it "is valid" do
    expect(disbursement).to be_valid
  end
end
