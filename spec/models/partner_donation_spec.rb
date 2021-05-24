# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnerDonation, type: :model do
  fixtures "partner_donations"

  let(:partner_donation) { partner_donations(:partner_donation1) }

  it "is valid" do
    expect(partner_donation).to be_valid
  end
end
