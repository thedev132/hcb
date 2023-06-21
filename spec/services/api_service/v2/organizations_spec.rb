# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V2::FindOrganizations, type: :model do
  let(:partner_id) { partner.id }

  let(:service) do
    ApiService::V2::FindOrganizations.new(
      partner_id: partner_id,
    )
  end

  context "when partner does not exist" do
    let(:partner_id) { "999999" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when partner has no organizations" do
    let(:partner) { create(:partner) }

    it "returns an empty array" do
      result = service.run

      expect(result).to be_empty
    end
  end

  context "when partner has organizations" do
    let(:event) { create(:event) }
    let(:partner) { event.partner }

    it "returns an array of organizations" do
      result = service.run

      expect(result).to include(be_instance_of(Event))
    end
  end
end
