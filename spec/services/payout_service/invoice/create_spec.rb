# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayoutService::Invoice::Create do
  fixtures :canonical_transactions, :hashed_transactions, :raw_plaid_transactions, :canonical_hashed_mappings, :transactions, :fee_reimbursements, :events, :invoices, :sponsors

  let(:invoice) { invoices(:invoice2) }

  let(:attrs) do
    {
      invoice_id: invoice.id
    }
  end

  let(:service) { PayoutService::Invoice::Create.new(attrs) }

  before do
    allow(service).to receive(:funds_available?).and_return(true)
    allow_any_instance_of(InvoicePayout).to receive(:create_stripe_payout).and_return(true)
    allow_any_instance_of(Sponsor).to receive(:create_stripe_customer).and_return(true)
    allow_any_instance_of(Sponsor).to receive(:update_stripe_customer).and_return(true)
  end

  it "creates a payout" do
    expect do
      result = service.run
    end.to change(InvoicePayout, :count).by(1)
  end

  it "creates a fee_reimbursement" do
    expect do
      result = service.run
    end.to change(FeeReimbursement, :count).by(1)
  end

  it "updates invoice with relationships" do
    expect(invoice.payout_id).to eql(nil)
    expect(invoice.fee_reimbursement_id).to eql(nil)

    service.run

    invoice.reload

    expect(invoice.payout_id).to_not eql(nil)
    expect(invoice.fee_reimbursement_id).to_not eql(nil)
  end
end
