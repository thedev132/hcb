# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiService::V2::GenerateLoginToken, type: :model do
  let(:user) { create(:user) }
  let(:event) { create(:event, :partnered) }
  let(:partner) { event.partner }

  let(:partner_id) { partner.id }
  let(:organization_public_id) { event.public_id }

  let(:service) {
    ApiService::V2::GenerateLoginToken.new(
      partner:,
      user_email: user.email,
      organization_public_id:
    )
  }

  before do
    create(:organizer_position, event:, user:)
  end

  it "creates a login token" do
    expect do
      service.run
    end.to change(LoginToken, :count).by(1)
  end

  it "creates with the login url" do
    url = service.run.login_url

    expect(url).to eql("#{Rails.application.routes.url_helpers.root_url}api/v2/login?login_token=#{LoginToken.last.token}")
  end

  it "idempotently creates" do
    service.run

    expect do
      service.run
    end.to_not raise_error
  end

  context "when partner is not tied to organization" do
    let(:partner) { create(:partner) }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when organization_public_id does not exist" do
    let(:organization_public_id) { "event8787878" }

    it "raises a 404" do
      expect do
        service.run
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
