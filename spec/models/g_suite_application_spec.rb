# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuiteApplication, type: :model do
  fixtures "g_suite_applications"

  let(:g_suite_application) { g_suite_applications(:g_suite_application1) }

  it "is valid" do
    expect(g_suite_application).to be_valid
  end

  context "when missing domain" do
    it "is not valid" do
      g_suite_application.domain = nil

      expect(g_suite_application).to_not be_valid
    end
  end
end
