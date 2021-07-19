# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::DonationsStart, type: :model do
  fixtures "partners", "events"

  let(:partner) { partners(:partner1) }
  let(:event) { events(:event1) }

  let(:partner_id) { partner.id }
  let(:organization_identifier) { event.organization_identifier }

  let(:attrs) do
    {
      partner_id: partner_id,
      organization_identifier: organization_identifier
    }
  end

  let(:service) { ApiService::V1::DonationsStart.new(attrs) }

  it "does not create partner donation" do
    expect do
      service.run
    end.to raise_error(ArgumentError)
  end

  context "when event is approved" do
    before do
      event.mark_approved!
    end

    it "creates a partner donation" do
      expect do
        service.run
      end.to change(PartnerDonation, :count).by(1)
    end
  end
end
