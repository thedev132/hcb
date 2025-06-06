# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventMappingEngine::Nightly do
  let(:service) { EventMappingEngine::Nightly.new }

  it "succeeds" do
    expect(service).to receive(:map_stripe_transactions!).and_return(true)
    expect(service).to receive(:map_column_account_number_transactions!).and_return(true)
    expect(service).to receive(:map_stripe_top_ups!).and_return(true)
    expect(service).to receive(:map_hcb_codes_short!).and_return(true)

    service.run
  end
end
