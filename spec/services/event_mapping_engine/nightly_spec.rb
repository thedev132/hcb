# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventMappingEngine::Nightly do
  let(:service) { EventMappingEngine::Nightly.new }

  it 'succeeds' do
    expect(service).to receive(:map_historical!).and_return(true)
    expect(service).to receive(:map_github!).and_return(true)

    service.run
  end
end
