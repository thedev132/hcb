# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPendingStripeTransaction, type: :model do
  fixtures "raw_pending_stripe_transactions"

  let(:raw_pending_stripe_transaction) { raw_pending_stripe_transactions(:raw_pending_stripe_transaction1) }

  it "is valid" do
    expect(raw_pending_stripe_transaction).to be_valid
  end

  describe "#authorization_method" do
    it "returns it in human friendly form" do
      expect(raw_pending_stripe_transaction.authorization_method).to eql("online")
    end
  end
end
