# frozen_string_literal: true

require "rails_helper"

RSpec.describe InvoiceService::Create, type: :model do
  fixtures  "users", "events", "organizer_positions"

  let(:user) { users(:user1) }
  let(:event) { events(:event1) }

  let(:event_id) { event.id }
  let(:due_date) { "2022-12-12" }
  let(:item_description) { "Invoice Description" }
  let(:item_amount) { "100.00" }
  let(:current_user) { user }
  let(:sponsor_id) { nil }
  let(:sponsor_name) { "Sponsor Name" }
  let(:sponsor_email) { "sponsor@email.com" }
  let(:sponsor_address_line1) { "123 Main St" }
  let(:sponsor_address_line2) { nil }
  let(:sponsor_address_city) { "Santa Monica" }
  let(:sponsor_address_state) { "CA" }
  let(:sponsor_address_postal_code) { "90401" }

  let(:attrs) do
    {
      event_id: event_id,
      due_date: due_date,
      item_description: item_description,
      item_amount: item_amount,
      current_user: current_user,
      sponsor_id: sponsor_id,
      sponsor_name: sponsor_name,
      sponsor_email: sponsor_email,
      sponsor_address_line1: sponsor_address_line1,
      sponsor_address_line2: sponsor_address_line2,
      sponsor_address_city: sponsor_address_city,
      sponsor_address_state: sponsor_address_state,
      sponsor_address_postal_code: sponsor_address_postal_code
    }
  end

  let(:service) { InvoiceService::Create.new(attrs) }
  
  let(:stripe_invoice_item) { double("StripeInvoice", id: 1) }
  let(:stripe_invoice_values) do
    {
      send_invoice: true,
      id: 1,
      amount_due: 100_00,
      amount_paid: 100_00,
      amount_remaining: 100_00,
      attempt_count: 1,
      attempted: true,
      auto_advance: false,
      due_date: 12345689,
      ending_balance: 100_00,
      finalized_at: "2021-12-12",
      hosted_invoice_url: "http://example.com",
      invoice_pdf: "http://example.com",
      livemode: false,
      description: "Invoice Memo",
      number: 1234,
      starting_balance: 0,
      statement_descriptor: "Statement Descriptor",
      status: "paid",
      charge: double("charge", id: 1, payment_method_details: double("payment_method_detail", type: nil)),
      subtotal: 100_00,
      tax: 0,
      tax_percent: 0,
      total: 100_00,
    }
  end
  let(:stripe_invoice) { double("StripeInvoice", stripe_invoice_values) }

  it "creates an invoice" do
    expect do
      service.run
    end.to change(Invoice, :count).by(1)
  end

  it "creates a stripe invoice item" do
    expect(::StripeService::InvoiceItem).to receive(:create).and_return(stripe_invoice_item)
    expect(::StripeService::Invoice).to receive(:create).and_return(stripe_invoice)

    service.run
  end

end
