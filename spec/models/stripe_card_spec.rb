# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeCard, type: :model do
  context "without stripe id" do
    let(:stripe_card) { create(:stripe_card) }

    it "is valid" do
      expect(stripe_card).to be_valid
    end
  end

  context "with stripe id" do
    let(:stripe_card) { create(:stripe_card, :with_stripe_id) }

    it "is valid" do
      expect(stripe_card).to be_valid
    end
  end
end
