# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V2::DonationsNew, type: :model do
  let(:event) { create(:event) }
  let(:partner) { event.partner }

  let(:service) {
    ApiService::V2::DonationsNew.new(
      partner_id: partner.id,
      organization_public_id: event.public_id
    )
  }

  context "when event is approved (the default state)" do
    it "creates a partner donation" do
      expect do
        service.run
      end.to change(PartnerDonation, :count).by(1)
    end
  end
end
