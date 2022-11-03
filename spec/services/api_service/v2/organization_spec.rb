# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V2::FindOrganization, type: :model do
  let(:event) { create(:event) }
  let(:partner) { event.partner }

  context "when partner and organization identifier exist" do
    let(:service) {
      ApiService::V2::FindOrganization.new(
        partner_id: partner.id,
        organization_public_id: event.public_id
      )
    }

    it "returns an organization" do
      result = service.run

      expect(result).to eq(event)
    end
  end

  context "when partner does not exist" do
    let(:service) {
      ApiService::V2::FindOrganization.new(
        partner_id: "999999",
        organization_public_id: event.public_id
      )
    }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when partner is not affiliated with the organizatino" do
    let(:service) {
      ApiService::V2::FindOrganization.new(
        partner_id: create(:partner).id,
        organization_public_id: event.public_id
      )
    }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when organization identifier does not exist" do
    let(:service) {
      ApiService::V2::FindOrganization.new(
        partner_id: partner.id,
        organization_public_id: "org_1234"
      )
    }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
