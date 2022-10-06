# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPendingPartnerDonationTransaction, type: :model do
  let(:partner_donation) { create(:partner_donation) }

  let(:raw_pending_partner_donation_transaction) { create(:raw_pending_partner_donation_transaction, partner_donation_transaction_id: partner_donation.id) }

  it "is valid" do
    expect(raw_pending_partner_donation_transaction).to be_valid
  end

  describe "#partner_donation" do
    it "returns partner donation" do
      expect(raw_pending_partner_donation_transaction.partner_donation).to eql(partner_donation)
    end
  end
end
