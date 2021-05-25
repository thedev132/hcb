# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::Organizations, type: :model do
  fixtures "partners", "events"

  let(:partner) { partners(:partner1) }
  let(:partner_id) { partner.id }

  let(:attrs) do
    {
      partner_id: partner_id,
    }
  end

  let(:service) { ApiService::V1::Organizations.new(attrs) }

  context "when partner does not exist" do
    let(:partner_id) { "999999" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when partner has no organizations" do
    let(:partner) { partners(:partnerWithNoOrganizations) }

    it "returns an empty array" do
      result = service.run

      expect(result).to be_empty
    end
  end

  context "when partner has organizations" do
    it "returns an array of organizations" do
      result = service.run

      expect(result).to include( be_instance_of(Event) )
    end
  end
end
