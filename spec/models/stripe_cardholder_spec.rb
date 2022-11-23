# frozen_string_literal: true

require "rails_helper"

RSpec.describe StripeCardholder, type: :model do
  let(:stripe_cardholder) { create(:stripe_cardholder) }

  it "is valid" do
    expect(stripe_cardholder).to be_valid
  end
end
