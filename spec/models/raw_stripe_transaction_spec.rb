# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawStripeTransaction, type: :model do
  it "is valid" do
    raw_stripe_transaction = create(:raw_stripe_transaction)
    expect(raw_stripe_transaction).to be_valid
  end
end
