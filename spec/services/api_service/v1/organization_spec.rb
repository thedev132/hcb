# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V1::Organization, type: :model do
  fixtures "partners", "events"

  let(:partner) { partners(:partner1) }
  let(:partner_id) { partner.id }
  
	let(:event) { events(:event1) }
  let(:organization_identifier) { event.organization_identifier }
  let(:status) { event.aasm_state }

  let(:attrs) do
    {
      partner_id: partner_id,
      organization_identifier: organization_identifier,
    }
  end

  let(:service) { ApiService::V1::Organization.new(attrs) }

  context "when partner does not exist" do
    let(:partner_id) { "999999" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when organization identifier does not exists" do
    let(:organization_identifier) { "org_1234" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when organization identifier exists" do
    let(:organization_identifier) { "event1" }

    it "returns an organization" do
      result = service.run

      expect(result).to be_instance_of(Event)
    end
  end
end
