# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayoutService::Donation::Create do
  let(:donation) { create(:donation, aasm_state: :in_transit) }

  let(:service) { PayoutService::Donation::Create.new(donation_id: donation.id) }

  before do
    allow(service).to receive(:funds_available?).and_return(true)
    allow_any_instance_of(DonationPayout).to receive(:create_stripe_payout).and_return(true)
  end

  it "creates a payout" do
    expect do
      service.run
    end.to change(DonationPayout, :count).by(1)
  end

  it "creates a fee_reimbursement" do
    expect do
      service.run
    end.to change(FeeReimbursement, :count).by(1)
  end

  it "updates donation with relationships" do
    expect(donation.payout_id).to be_nil
    expect(donation.fee_reimbursement_id).to be_nil

    service.run

    donation.reload

    expect(donation.payout_id).to be_present
    expect(donation.fee_reimbursement_id).to be_present
  end
end
