# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:transaction) { create(:transaction) }

  it "is valid" do
    expect(transaction).to be_valid
  end
end
