# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeCardholder, type: :model do
  fixtures "stripe_cards", "stripe_cardholders", "users"

  let(:stripe_cardholder) { stripe_cardholders(:stripe_cardholder1) }

  it "is valid" do
    expect(stripe_cardholder).to be_valid
  end
end
