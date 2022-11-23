# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invoice, type: :model do
  let(:invoice) { create(:invoice) }

  it "is valid" do
    expect(invoice).to be_valid
  end
end
