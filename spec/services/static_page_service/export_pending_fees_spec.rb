# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaticPageService::ExportPendingFees, type: :model do
  fixtures  "users", "events",  "g_suites", "g_suite_applications", "organizer_positions"

  let(:service) { StaticPageService::ExportPendingFees.new }

  describe "#run" do
    it "returns csv of pending event fees" do
      result = service.run

      csv = <<~CSV
        amount,transaction_name
        10000.0,#{Event.first.id} Hack Club Bank Fee
      CSV

      expect(result).to eql(csv)
    end
  end
end
