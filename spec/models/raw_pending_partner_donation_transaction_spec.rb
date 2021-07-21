# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPendingPartnerDonationTransaction, type: :model do
  fixtures "raw_pending_partner_donation_transactions", "partner_donations"

  let(:partner_donation) { partner_donations(:partner_donation2) }

  let(:raw_pending_partner_donation_transaction) { raw_pending_partner_donation_transactions(:raw_pending_partner_donation_transaction1) }

  it "is valid" do
    expect(raw_pending_partner_donation_transaction).to be_valid
  end

  describe "#partner_donation" do
    it "returns partner donation" do
      expect(raw_pending_partner_donation_transaction.partner_donation).to eql(partner_donation)
    end
  end
end
