# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPendingStripeTransaction, type: :model do
  let(:raw_pending_stripe_transaction) { create(:raw_pending_stripe_transaction) }

  it "is valid" do
    expect(raw_pending_stripe_transaction).to be_valid
  end

  describe "#authorization_method" do
    it "returns it in human friendly form" do
      expect(raw_pending_stripe_transaction.authorization_method).to eql("online")
    end
  end
end
