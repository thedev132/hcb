# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayoutService::Invoice::Create do
  let(:invoice) { create(:invoice) }

  let(:attrs) do
    {
      invoice_id: invoice.id
    }
  end

  let(:service) { PayoutService::Invoice::Create.new(**attrs) }

  before do
    allow(service).to receive(:funds_available?).and_return(true)
    allow(service).to receive(:charge).and_return(true)
    allow_any_instance_of(InvoicePayout).to receive(:create_stripe_payout).and_return(true)
    allow_any_instance_of(Sponsor).to receive(:create_stripe_customer).and_return(true)
    allow_any_instance_of(Sponsor).to receive(:update_stripe_customer).and_return(true)
  end

  it "creates a payout" do
    expect do
      service.run
    end.to change(InvoicePayout, :count).by(1)
  end

  it "creates a fee_reimbursement" do
    expect do
      service.run
    end.to change(FeeReimbursement, :count).by(1)
  end

  it "updates invoice with relationships" do
    expect(invoice.payout_id).to be_nil
    expect(invoice.fee_reimbursement_id).to be_nil

    service.run

    invoice.reload

    expect(invoice.payout_id).to be_present
    expect(invoice.fee_reimbursement_id).to be_present
  end
end
