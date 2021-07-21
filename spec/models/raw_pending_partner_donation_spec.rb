# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawPendingPartnerDonationTransaction, type: :model do
  fixtures "raw_pending_partner_donation_transactions"

  let(:raw_pending_partner_donation_transaction) { raw_pending_partner_donation_transactions(:raw_pending_partner_donation_transaction1) }

  it "is valid" do
    expect(raw_pending_partner_donation_transaction).to be_valid
  end
end
