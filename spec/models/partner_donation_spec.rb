# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnerDonation, type: :model do
  let(:partner_donation) { create(:partner_donation) }

  it "is valid" do
    expect(partner_donation).to be_valid
  end

  context "hcb code" do
    let(:event) { create(:event) }

    it "generates a hcb code" do
      pd = event.partner_donations.create!

      expect(pd.reload.hcb_code).to_not be_nil
    end
  end
end
