# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventMappingEngine::Map::Historical do
  fixtures :canonical_transactions, :hashed_transactions, :raw_plaid_transactions, :canonical_hashed_mappings, :transactions

  let(:service) { EventMappingEngine::Map::Historical.new }

  it 'maps historical canonical transaction to an event' do
    expect do
      service.run
    end.to change(CanonicalTransaction.unmapped, :count).by(-1)
  end

  context 'when canonical transaction has more than 1 hashed transaction' do
    let(:hashed_transaction) { hashed_transactions(:hashed_transaction1) }
    let(:canonical_hashed_mapping) { canonical_hashed_mappings(:canonical_hashed_mapping1) }

    before do
      attrs = hashed_transaction.attributes 
      attrs.delete('id')
      ht = HashedTransaction.create!(attrs)

      attrs = canonical_hashed_mapping.attributes
      attrs[:hashed_transaction_id] = ht.id
      attrs.delete('id')

      CanonicalHashedMapping.create!(attrs)
    end

    it 'raises ArgumentError' do
      expect do
        service.run
      end.to raise_error(ArgumentError)
    end
  end
end
