# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventMappingEngine::Map::Historical do
  fixtures :canonical_transactions

  let(:service) { EventMappingEngine::Map::Historical.new }

  it 'maps historical canonical transaction to an event' do
    expect do
      service.run
    end.to change(CanonicalTransaction.unmapped, :count).by(-1)
  end
end
