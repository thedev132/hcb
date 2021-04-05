# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeCard, type: :model do
  fixtures "stripe_cards", "stripe_cardholders"

  let(:stripe_card) { stripe_cards(:stripe_card1) }

  it "is valid" do
    expect(stripe_card).to be_valid
  end
end
