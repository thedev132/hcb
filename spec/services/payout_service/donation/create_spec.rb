# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayoutService::Donation::Create do
  fixtures :canonical_transactions, :hashed_transactions, :raw_plaid_transactions, :canonical_hashed_mappings, :transactions, :fee_reimbursements, :events, :donations

  let(:donation) { donations(:donation2) }

  let(:attrs) do
    {
      donation_id: donation.id
    }
  end

  let(:service) { PayoutService::Donation::Create.new(attrs) }

  before do
    allow(service).to receive(:funds_available?).and_return(true)
    allow_any_instance_of(DonationPayout).to receive(:create_stripe_payout).and_return(true)
  end

  it "creates a payout" do
    expect do
      result = service.run
    end.to change(DonationPayout, :count).by(1)
  end

  it "creates a fee_reimbursement" do
    expect do
      result = service.run
    end.to change(FeeReimbursement, :count).by(1)
  end

  it "updates donation with relationships" do
    expect(donation.payout_id).to eql(nil)
    expect(donation.fee_reimbursement_id).to eql(nil)

    service.run

    donation.reload

    expect(donation.payout_id).to_not eql(nil)
    expect(donation.fee_reimbursement_id).to_not eql(nil)
  end
end
